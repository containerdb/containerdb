class StorageProvider::S3Provider < StorageProvider::BaseProvider
  def default_environment_variables
    {
      'AWS_ACCESS_TOKEN' => nil,
      'AWS_SECRET_KEY' => nil,
      'AWS_BUCKET_NAME' => nil
    }
  end

  def required_environment_variables
    default_environment_variables.keys
  end
end
