class Service::MemsqlService < Service::BaseService
  def default_environment_variables
    {
      'MEMSQL_ROOT_USERNAME' => 'root'
    }
  end

  def required_environment_variables
    ['MEMSQL_ROOT_USERNAME']
  end

  def connection_string
    "mysql://#{service.environment_variables['MEMSQL_ROOT_USERNAME']}:@#{service.host}:#{service.port}"
  end

  def connection_command
    "mysql -h#{service.host} -u#{service.environment_variables['MEMSQL_ROOT_USERNAME']} -P#{service.port}"
  end

  def container_port
    3306
  end

  def data_directory
    '/memsql'
  end

  def publicly_accessible
    true
  end
end
