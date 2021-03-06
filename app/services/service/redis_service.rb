class Service::RedisService < Service::BaseService
  def default_environment_variables
    {
      'REDIS_PASS' => SecureRandom.hex
    }
  end

  def required_environment_variables
    ['REDIS_PASS']
  end

  def connection_string
    "redis://:#{service.environment_variables['REDIS_PASS']}@#{service.host}:#{service.port}"
  end

  def connection_command
    "redis-cli -h #{service.host} -a #{service.environment_variables['REDIS_PASS']} -p #{service.port}"
  end

  def container_port
    6379
  end

  def data_directory
    '/data'
  end

  def backup_environment_variables
    {
      REDIS_HOST: service.host,
      REDIS_PASSWORD: service.environment_variables['REDIS_PASS'],
      REDIS_PORT: service.port,
    }
  end

  def backup_file_suffix
    'rdb'
  end

  def backup_script_path
    'app/redis/backup.sh'
  end
end
