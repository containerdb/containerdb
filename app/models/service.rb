class Service < ApplicationRecord

  SERVICES = {
    redis: 'tutum/redis',
    postgres: 'postgres',
    mysql: 'mysql'
  }

  validates :name, presence: true
  validates :port, uniqueness: true, presence: true
  validates :service_type, presence: true, inclusion: { in: Service::SERVICES.keys.map(&:to_s) }
  validates :image, presence: true, inclusion: { in: Service::SERVICES.values }
  validate :validate_environment_variables

  after_initialize :assign_port, :assign_environment_variables, :assign_image
  before_destroy :destroy_container

  def container
    if container_id.blank?
      # Create the Docker container
      container = Docker::Container.create(
        'name' => "#{image.parameterize}-#{id}",
        'Image' => image,
        'Env' => container_env,
        'ExposedPorts' => { "#{service.container_port}/tcp" => {} },
        'HostConfig' => {
          'PortBindings' => {
            "#{service.container_port}/tcp" => [{ 'HostPort' => port.to_s }]
          }
        }
      )

      # Track the container ID so we can destroy it later
      self.update(container_id: container.id)
      container
    else
      Docker::Container.get(container_id)
    end
  end

  def destroy_container
    if container_id.present?
      container.kill!
      container.delete
    end
  rescue Docker::Error::NotFoundError
    nil
  end

  def connection_string
    service.connection_string
  end

  def connection_command
    service.connection_command
  end

  def backup_command
    service.backup_command
  end

  def can_backup?
    backup_command.present?
  rescue NotImplementedError
    false
  end

  protected

  def service
    @_service ||= "#{service_type.capitalize}Service".constantize.new(self)
  end

  def container_env
    self.environment_variables.map {|key, value| "#{key}=#{value}" }
  end

  # @todo handle collisions
  def assign_port
    self.port ||= (rand(65000 - 1024) + 1024)
  end

  def assign_image
    self.image ||= Service::SERVICES[self.service_type.to_sym]
  end

  def assign_environment_variables
    self.environment_variables = service.default_environment_variables.merge(self.environment_variables)
  end

  def validate_environment_variables
    service.required_environment_variables.each do |variable|
      errors.add(:environment_variables, "#{variable} is required") unless environment_variables[variable].present?
    end
  end
end
