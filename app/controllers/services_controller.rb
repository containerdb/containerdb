class ServicesController < ApplicationController

  def index
    @services = Service.all.order(created_at: :desc)
  end

  def destroy
    @service = Service.find(params[:id])
    @service.destroy unless @service.locked?
    redirect_to :back
  end

  def new
    return redirect_to choose_services_path unless params[:service].present?
    @service = Service.new(service_type: params[:service], hosted: params[:hosted])
  end

  def create
    @service = Service.new(create_params)
    if @service.save
      StartServiceJob.perform_later(@service) if @service.hosted?
      redirect_to services_path
    else
      render :new
    end
  end

  private

  def create_params
    # Create a temp service so that we can get the default environment variable keys.
    # @todo there will be a cleaner way to do this
    service_env_keys = Service.new(params.require(:service).permit(:service_type, :hosted)).default_environment_variables.keys

    params.require(:service).permit(:service_type, :name, :hosted, :port, environment_variables: service_env_keys)
  end
end
