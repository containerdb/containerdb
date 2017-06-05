class BackupsController < ApplicationController
  def create
    service = Service.find(params[:service_id])
    service.backup
    redirect_to :back
  end

  def destroy
    service = Service.find(params[:service_id])
    service.backups.find(params[:id]).destroy
    redirect_to :back
  end
end
