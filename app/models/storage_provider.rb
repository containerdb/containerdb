class StorageProvider < ApplicationRecord

  PROVIDERS = ['s3', 'local']

  validates :name, presence: true
  validates :provider, presence: true, inclusion: { in: PROVIDERS }
  validate :validate_environment_variables

  def label_method
    "[#{provider}] #{name}"
  end

  def storage_provider_service
    @_storage_provider_service ||= "StorageProvider::#{provider.to_s.capitalize}Provider".constantize.new
  end

  def default_environment_variables
    storage_provider_service.default_environment_variables
  end

  def required_environment_variables
    storage_provider_service.required_environment_variables
  end

  def validate_environment_variables
    required_environment_variables.each do |variable|
      errors.add(:environment_variable, "\"#{variable}\" is required") unless environment_variables[variable].present?
    end
  end
end
