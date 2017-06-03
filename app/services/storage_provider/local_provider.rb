class StorageProvider::LocalProvider < StorageProvider::BaseProvider
  def default_environment_variables
    {
      'DIRECTORY' => nil
    }
  end

  def required_environment_variables
    default_environment_variables.keys
  end
end
