class Service < ApplicationRecord

  validates :port, uniqueness: true, presence: true
  validates :password, presence: true
  validates :image, presence: true

  after_initialize :assign_port, :assign_password

  def container
    if container_id.blank?
      # Create the Docker container
      container = Docker::Container.create(
        'name' => "#{image}-#{id}",
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
      container
    else
      Docker::Container.get(container_id)
    end
  end

  # @todo handle collisions
  def assign_port
    self.port ||= (rand(65000 - 1024) + 1024)
  end

  def assign_password
    self.password ||= SecureRandom.hex
  end

  def connection_string
    case image.to_sym
    when :postgres
      "postgres://postgres:#{password}@#{ENV['HOST']}:#{port}"
    end
  end

  def connection_command
    case image.to_sym
    when :postgres
      "PGPASSWORD='#{password}' psql -U postgres -h #{ENV['HOST']} -p #{port}"
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
