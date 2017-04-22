class Service::PostgresService < Service::BaseService
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
    "postgres://#{service.environment_variables['POSTGRES_USER']}:#{service.environment_variables['POSTGRES_PASSWORD']}@#{service.host}:#{service.port}"
  end

  def connection_command
    "PGPASSWORD='#{service.environment_variables['POSTGRES_PASSWORD']}' psql -U #{service.environment_variables['POSTGRES_USER']} -h #{service.host} -p #{service.port}"
  end

  def container_port
    5432
  end

  def backup_environment_variables
    {
      DB_USER: service.environment_variables['POSTGRES_USER'],
      DB_HOST: service.host,
      DB_PORT: service.port,
      DB_PASS: service.environment_variables['POSTGRES_PASSWORD'],
    }
  end

  def backup_file_suffix
    'sql'
  end

  def backup_script_path
    'app/postgres/backup.sh'
  end
end
