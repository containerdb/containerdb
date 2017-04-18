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
    @service = Service.new(service_type: params[:service])
  end

  def create
    @service = Service.new(params.require(:service).permit(:service_type, :name))
    if @service.save
      StartServiceJob.perform_later(@service)
      redirect_to services_path
    else
      render :new
    end
  end
end
