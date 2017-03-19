class Service < ApplicationRecord

  validates :port, uniqueness: true, presence: true
  validates :password, presence: true
  validates :image, presence: true

  after_initialize :assign_port, :assign_password

  def create_container
    # @note tmp
    Docker.url = "#{docker_host}:#{docker_port}"

    # Create the Docker container
    container = Docker::Container.create(
      'name' => "#{image}-#{Time.now.to_i}",
      'Image' => image,
      'Env' => container_env,
      'ExposedPorts' => { "#{container_port}/tcp" => {} },
      'HostConfig' => {
        'PortBindings' => {
          "#{container_port}/tcp" => [{ 'HostPort' => port.to_s }]
        }
      }
    )

    # Start the container
    container.start

    # Track the container ID so we can destroy it later
    self.update(container_id: container.id)
  end

  # @note tmp
  def docker_host
    '127.0.0.1'
  end

  # @note tmp
  def docker_port
    '4243'
  end

  # @todo handle collisions
  def assign_port
    self.port ||= rand(99999)
  end

  def assign_password
    self.password ||= SecureRandom.hex
  end

  def connection_string
    case image.to_sym
    when :postgres
      "postgres://postgres:#{password}@#{docker_host}:#{port}"
    end
  end

  def connection_command
    case image.to_sym
    when :postgres
      "PGPASSWORD='#{password}' psql -U postgres -h #{docker_host} -p #{port}"
    end
  end

  def container_port
    case image.to_sym
    when :postgres
      5432
    end
  end

  def container_env
    case image.to_sym
    when :postgres
      ["POSTGRES_PASSWORD=#{password}"]
    end
  end
end
