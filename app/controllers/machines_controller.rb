class MachinesController < ApplicationController
  def index
    @machines = Machine.eager_load(:services).order(created_at: :desc)
  end

  def new
    @machine = Machine.new
  end

  def create
    @machine = Machine.new(create_params)
    if @machine.save
      redirect_to machines_path
    else
      render :new
    end
  end

  private

  def create_params
    params.require(:machine).permit(:name, :docker_url)
  end
end
