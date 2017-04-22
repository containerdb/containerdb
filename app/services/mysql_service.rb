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
    "mysql://root:#{service.environment_variables['MYSQL_ROOT_PASSWORD']}@#{service.host}:#{service.port}"
  end

  def connection_command
    "mysql -h#{service.host} -uroot -p#{service.environment_variables['MYSQL_ROOT_PASSWORD']} -P#{service.port}"
  end

  def container_port
    3306
  end

  def backup_environment_variables
    {
      DB_USER: 'root',
      DB_HOST: service.host,
      DB_PORT: service.port,
      DB_PASS: service.environment_variables['MYSQL_ROOT_PASSWORD'],
    }
  end

  def backup_file_suffix
    'sql'
  end

  def backup_script_path
    'app/mysql/backup.sh'
  end
end
