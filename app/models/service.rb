class Service < ApplicationRecord

  DEFAULT_SERVICE_TYPE = 'redis'
  SERVICES = {
    redis: [
      'containerdb/redis:3.2.9-alpine',
    ],
    postgres: [
      'postgres:9.6.3',
      'postgres:9.6.3-alpine',
      'postgres:5.5.7',
      'postgres:5.5.7-alpine',
      'postgres:5.4.12',
      'postgres:5.4.12-alpine',
      'postgres:5.3.17',
      'postgres:5.3.17-alpine',
      'postgres:5.2.21',
      'postgres:5.2.21-alpine',
    ],
    mysql: [
      'mysql:5.7.18',
      'mysql:8.0.1',
      'mysql:5.6.36',
      'mysql:5.5.56',
    ]
  }

  validates :name, presence: true
  validates :machine, presence: true

  validates :port, presence: true
  validates :port, uniqueness: { scope: [:machine, :hosted] }, if: :hosted?

  validates :backup_storage_provider, presence: true, allow_nil: true

  validates :service_type, presence: true, inclusion: { in: Service::SERVICES.keys.map(&:to_s) }
  validate :validate_environment_variables
  validate :validate_image, if: :hosted?

  after_initialize :assign_default_service_type
  after_initialize :assign_port, if: :hosted?
  after_initialize :assign_environment_variables

  before_destroy :destroy_container, if: :hosted?

  has_many :backups
  belongs_to :backup_storage_provider, class_name: 'StorageProvider', optional: true
  belongs_to :machine

  def backup(inline: false)
    if inline
      BackupWorker.new.perform(self.backups.create.id)
    else
      BackupWorker.perform_async(self.backups.create.id)
    end
  end

  def container
    Docker::Container.get(container_id, machine.docker) if container_id
  end

  def destroy_container
    if container_id.present?
      container.kill!
      container.delete
    end
  rescue Docker::Error::NotFoundError
    nil
  end

  def default_environment_variables
    variables = service.default_environment_variables

    # If this is an external service, we dont want any default variable assignments
    # We also want to be able to porvide a host
    unless hosted?
      variables.merge!('HOST' => nil)
      variables.each { |k, v| variables[k] = nil }
    end

    variables
  end

  def required_environment_variables
    variables = service.required_environment_variables
    variables += ['HOST'] unless hosted?
    variables
  end

  def connection_string
    service.connection_string
  end

  def connection_command
    service.connection_command
  end

  def backup_environment_variables
    service.backup_environment_variables
  end

  def backup_script_path
    service.backup_script_path
  end

  def backup_file_name
    service.backup_file_name
  end

  def host
    environment_variables['HOST'] || machine.hostname
  end

  def can_backup?
    backup_environment_variables.present? && backup_storage_provider.present?
  rescue NotImplementedError
    false
  end

  def container_env
    self.environment_variables.map do |key, value|
      "#{key}=#{value}"
    end
  end

  def service
    @_service ||= "Service::#{service_type.capitalize}Service".constantize.new(self)
  end

  def available_images
    Service::SERVICES[service_type.to_sym]
  end

  def external?
    !hosted?
  end

  protected

  def assign_default_service_type
    self.service_type ||= DEFAULT_SERVICE_TYPE
  end

  # @todo handle collisions
  def assign_port
    self.port ||= (rand(65000 - 1024) + 1024)
  end

  def assign_environment_variables
    self.environment_variables = default_environment_variables.merge(self.environment_variables)
  end

  def validate_environment_variables
    required_environment_variables.each do |variable|
      errors.add(:environment_variable, "\"#{variable}\" is required") unless environment_variables[variable].present?
    end
  end

  def validate_image
    if image.nil? || !available_images.include?(image)
      errors.add(:image, "is invalid. Must be #{available_images.join('or ')} ")
    end
  end
end
