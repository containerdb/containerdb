class RedisService < BaseService
  def default_environment_variables
    {
      'REDIS_PASS' => SecureRandom.hex
    }
  end

  def required_environment_variables
    ['REDIS_PASS']
  end

  def connection_string
    "redis://:#{service.environment_variables['REDIS_PASS']}@#{ENV['HOST']}:#{service.port}"
  end

  def connection_command
    "redis-cli -h #{ENV['HOST']} -a #{service.environment_variables['REDIS_PASS']} -p #{service.port}"
  end

  def container_port
    6379
  end
end
