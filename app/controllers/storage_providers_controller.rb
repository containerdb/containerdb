class StorageProvidersController < ApplicationController

  def index
    @providers = StorageProvider.all.order(created_at: :desc)
  end

  def new
    @provider = StorageProvider.new(provider: :s3)
  end

  def create
    @provider = StorageProvider.new(create_params)
    if @provider.save
      redirect_to storage_providers_path
    else
      render :new
    end
  end

  private

  def create_params
    provider_env_keys = StorageProvider.new(params.require(:storage_provider).permit(:provider)).default_environment_variables.keys
    params.require(:storage_provider).permit(:name, :provider, environment_variables: provider_env_keys)
  end

end
