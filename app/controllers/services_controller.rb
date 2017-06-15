class ServicesController < ApplicationController
  def index
    @services = Service.eager_load(:backup_storage_provider, :machine).order(created_at: :desc)
  end

  def destroy
    @service = Service.find(params[:id])
    @service.destroy unless @service.locked?
    redirect_to root_path
  end

  def new
    return redirect_to choose_services_path unless params[:service].present?
    @service = Service.new(service_type: params[:service], hosted: params[:hosted])
  end

  def create
    @service = Service.new(create_params)
    if @service.save
      StartServiceWorker.perform_async(@service.id) if @service.hosted?
      redirect_to services_path
    else
      render :new
    end
  end

  def update
    @service = Service.find(params[:id])
    if @service.update(update_params)
      redirect_to edit_service_path(@service)
    else
      render :edit
    end
  end

  def edit
    @service = Service.find(params[:id])
  end

  private

  def update_params
    params.require(:service).permit(:name, :backup_storage_provider_id)
  end

  def create_params
    params.require(:service).permit(
      :service_type, :name, :hosted, :image,
      :port, :backup_storage_provider_id, :machine_id,
      environment_variables: service_env_keys,
    )
  end

  def service_env_keys
    # Create a temp service so that we can get the default environment variable keys.
    # @todo there will be a cleaner way to do this
    Service.new(params.require(:service).permit(:service_type, :hosted)).default_environment_variables.keys
  end
end
