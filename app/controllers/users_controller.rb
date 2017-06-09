class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def index
    @users = User.order(created_at: :desc)
  end

  def create
    @user = User.new(create_params)
    if @user.save
      flash[:info] = "#{@user.email} has been created with the password of #{create_params[:password]}"
      redirect_to users_path
    else
      render :new
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to :back
  end

  private

  def create_params
    params.require(:user).permit(:email, :password)
  end
end
