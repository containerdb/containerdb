class BaseService

  attr_reader :service
  def initialize(service)
    @service = service
  end

  def not_implemented!
    raise NotImplementedError.new('This method has not been implemented for this Service')
  end

  # Environment Variables
  alias_method :default_environment_variables,    :not_implemented!
  alias_method :required_environment_variables,   :not_implemented!

  # Container Settings
  alias_method :connection_string,                :not_implemented!
  alias_method :connection_command,               :not_implemented!
  alias_method :container_port,                   :not_implemented!

  # Backup/Restore
  alias_method :backup_environment_variables,     :not_implemented!
  alias_method :backup_script_path,               :not_implemented!
  alias_method :backup_file_suffix,               :not_implemented!

  def backup_file_name
    "#{service.host}_#{service.service_type}_#{service.name.parameterize}_#{Time.now.to_i}.#{backup_file_suffix}"
  end
end
