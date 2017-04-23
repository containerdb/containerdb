class Service < ApplicationRecord

  SERVICES = {
    redis: 'tutum/redis',
    postgres: 'postgres',
    mysql: 'mysql'
  }

  validates :name, presence: true

  validates :port, presence: true
  validates :port, uniqueness: { scope: :hosted }, if: :hosted?

  validates :backup_storage_provider, presence: true, allow_nil: true

  validates :service_type, presence: true, inclusion: { in: Service::SERVICES.keys.map(&:to_s) }
  validates :image, presence: true, inclusion: { in: Service::SERVICES.values }, if: :hosted?
  validate :validate_environment_variables

  after_initialize :assign_port, if: :hosted?
  after_initialize :assign_image, if: :hosted?
  after_initialize :assign_environment_variables

  before_destroy :destroy_container, if: :hosted?

  has_many :backups
  belongs_to :backup_storage_provider, class_name: 'StorageProvider', optional: true

  def backup(inline: false)
    if inline
      BackupJob.perform_now(self.backups.create)
    else
      BackupJob.perform_later(self.backups.create)
    end
  end

  def container
    Docker::Container.get(container_id) if container_id
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
    environment_variables['HOST'] || ENV['HOST']
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

  protected

  # @todo handle collisions
  def assign_port
    self.port ||= (rand(65000 - 1024) + 1024)
  end

  def assign_image
    self.image ||= Service::SERVICES[self.service_type.to_sym]
  end

  def assign_environment_variables
    self.environment_variables = default_environment_variables.merge(self.environment_variables)
  end

  def validate_environment_variables
    required_environment_variables.each do |variable|
      errors.add(:environment_variable, "\"#{variable}\" is required") unless environment_variables[variable].present?
    end
  end
end
