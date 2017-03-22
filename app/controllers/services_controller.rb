class ServicesController < ApplicationController

  def index
    @services = Service.all.order(created_at: :desc)
  end

  def new
    @service = Service.new(image: :postgres)
  end

  def create
    @service = Service.new(params.require(:service).permit(:image))
    if @service.save
      @service.container
      redirect_to services_path
    end
  end
end
