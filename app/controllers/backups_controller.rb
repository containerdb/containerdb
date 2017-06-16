class BackupsController < ApplicationController
  def create
    service = Service.find(params[:service_id])
    service.backup
    redirect_back fallback_location: service
  end

  def destroy
    service = Service.find(params[:service_id])
    service.backups.find(params[:id]).destroy
    redirect_back fallback_location: service
  end
end
