class BackupsController < ApplicationController
  def create
    service = Service.find(params[:service_id])
    service.backup
    redirect_back fallback_location: service
  end
end
