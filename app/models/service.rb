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

  def container
    if container_id.blank?
      # Create the Docker container
      container = Docker::Container.create(
        'name' => "#{image.parameterize}-#{id}",
        'Image' => image,
        'Env' => container_env,
        'ExposedPorts' => { "#{container_port}/tcp" => {} },
        'HostConfig' => {
          'PortBindings' => {
            "#{container_port}/tcp" => [{ 'HostPort' => port.to_s }]
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

  def connection_string
    case service_type.to_s
    when 'postgres'
      "postgres://#{environment_variables['POSTGRES_USER']}:#{environment_variables['POSTGRES_PASSWORD']}@#{ENV['HOST']}:#{port}"
    when 'mysql'
      "mysql://root:#{environment_variables['MYSQL_ROOT_PASSWORD']}@#{ENV['HOST']}:#{port}"
    when 'redis'
      "redis://:#{environment_variables['REDIS_PASS']}#{ENV['HOST']}:#{port}"
    end
  end

  def connection_command
    case service_type.to_s
    when 'postgres'
      "PGPASSWORD='#{environment_variables['POSTGRES_PASSWORD']}' psql -U #{environment_variables['POSTGRES_USER']} -h #{ENV['HOST']} -p #{port}"
    when 'mysql'
      "mysql -h#{ENV['HOST']} -uroot -p#{environment_variables['MYSQL_ROOT_PASSWORD']} -P#{port}"
    when 'redis'
      "redis-cli -h #{ENV['HOST']} -a #{environment_variables['REDIS_PASS']} -p #{port}"
    end
  end

  protected

  def container_port
    case service_type.to_s
    when 'postgres'
      5432
    when 'mysql'
      3306
    when 'redis'
      6379
    end
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
    self.environment_variables = self.default_environment_variables.merge(self.environment_variables)
  end

  def validate_environment_variables
    required_environment_variables.each do |variable|
      errors.add(:environment_variables, "#{variable} is required") unless environment_variables[variable].present?
    end
  end

  def required_environment_variables
    case service_type.to_s
    when 'postgres'
      ['POSTGRES_PASSWORD', 'POSTGRES_USER']
    when 'mysql'
      ['MYSQL_ROOT_PASSWORD']
    when 'redis'
      ['REDIS_PASS']
    else
      []
    end
  end

  def default_environment_variables
    case service_type.to_s
    when 'postgres'
      {
        'POSTGRES_PASSWORD' => SecureRandom.hex,
        'POSTGRES_USER' => 'postgres'
      }
    when 'redis'
      {
        'REDIS_PASS' => SecureRandom.hex
      }
    when 'mysql'
      {
        'MYSQL_ROOT_PASSWORD' => SecureRandom.hex
      }
    else
      {}
    end
  end
end
