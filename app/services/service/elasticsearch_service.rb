class Service::ElasticsearchService < Service::BaseService
  def default_environment_variables
    {
      'ELASTIC_PASSWORD' => SecureRandom.hex
    }
  end

  def required_environment_variables
    ['ELASTIC_PASSWORD']
  end

  def connection_string
    "http://elastic:#{service.environment_variables['ELASTIC_PASSWORD']}@#{service.host}:#{service.port}"
  end

  def connection_command
    "curl http://elastic:#{service.environment_variables['ELASTIC_PASSWORD']}@#{service.host}:#{service.port}"
  end

  def container_port
    9200
  end

  def data_directory
    '/usr/share/elasticsearch/data'
  end
end
