class ServicesController < ApplicationController

  def index
    @services = Service.all.order(created_at: :desc)
  end

  def new
    @service = Service.new(service_type: :postgres)
  end

  def create
    @service = Service.new(params.require(:service).permit(:service_type, :name))
    if @service.save
      @service.container.start
      redirect_to services_path
    end
  end
end
