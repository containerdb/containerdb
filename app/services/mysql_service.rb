class MysqlService < BaseService
  def default_environment_variables
    {
      'MYSQL_ROOT_PASSWORD' => SecureRandom.hex
    }
  end

  def required_environment_variables
    ['MYSQL_ROOT_PASSWORD']
  end

  def connection_string
    "mysql://root:#{service.environment_variables['MYSQL_ROOT_PASSWORD']}@#{ENV['HOST']}:#{service.port}"
  end

  def connection_command
    "mysql -h#{ENV['HOST']} -uroot -p#{service.environment_variables['MYSQL_ROOT_PASSWORD']} -P#{service.port}"
  end

  def container_port
    3306
  end

  def backup_command
    "mysqldump --all-databases --host=#{ENV['HOST']} --port=#{service.port} --user=root --password=#{service.environment_variables['MYSQL_ROOT_PASSWORD']}"
  end
end
