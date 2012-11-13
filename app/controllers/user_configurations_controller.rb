class UserConfigurationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user_configuration, only: [:edit, :update]

  def create
    @user_configuration =
        current_user.build_user_configuration(params[:user_configuration])
    if @user_configuration.save
      flash[:success] = "Settings updated"
      redirect_to root_path
    else
      render :edit
    end
  end

  def edit
  end

  def update
    if @user_configuration.update_attributes(params[:user_configuration])
      flash[:success] = "Settings updated"
      redirect_to root_path
    else
      render 'edit'
    end
  end

  private
    def find_user_configuration
      begin
        @user_configuration = current_user.user_configuration ||
            current_user.build_user_configuration
      end
    end
end