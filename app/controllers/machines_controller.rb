class MachinesController < ApplicationController
  def index
    @machines = Machine.eager_load(:services).order(created_at: :desc)
  end

  def new
    @machine = Machine.new
  end

  def edit
    @machine = Machine.find(params[:id])
  end

  def update
    @machine = Machine.find(params[:id])
    if @machine.update(update_params)
      redirect_to edit_machine_path(@machine)
    else
      render :edit
    end
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

  def update_params
    params.require(:machine).permit(:name)
  end

  def create_params
    params.require(:machine).permit(:name, :docker_url)
  end
end
