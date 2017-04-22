class StorageProvider::BaseProvider
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
end
