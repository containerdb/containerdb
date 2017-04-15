class PostgresService < BaseService
  def default_environment_variables
    {
      'POSTGRES_PASSWORD' => SecureRandom.hex,
      'POSTGRES_USER' => 'postgres'
    }
  end

  def required_environment_variables
    ['POSTGRES_PASSWORD', 'POSTGRES_USER']
  end

  def connection_string
    "postgres://#{service.environment_variables['POSTGRES_USER']}:#{service.environment_variables['POSTGRES_PASSWORD']}@#{ENV['HOST']}:#{service.port}"
  end

  def connection_command
    "PGPASSWORD='#{service.environment_variables['POSTGRES_PASSWORD']}' psql -U #{service.environment_variables['POSTGRES_USER']} -h #{ENV['HOST']} -p #{service.port}"
  end

  def container_port
    5432
  end
end
