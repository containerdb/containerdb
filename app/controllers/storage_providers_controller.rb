class StorageProvidersController < ApplicationController

  def index
    @providers = StorageProvider.all.order(created_at: :desc)
  end

  def choose
  end

  def new
    return redirect_to choose_storage_providers_path unless params[:provider].present?
    @provider = StorageProvider.new(provider: params[:provider])
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
