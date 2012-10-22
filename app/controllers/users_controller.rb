class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:show, :index, :edit, :update]
  before_filter :correct_user,   only: [:show, :edit, :update]
  before_filter :admin_user,     only: [:index, :destroy]
  before_filter :non_signed_in_user, only: [:new, :create]

  def index
    @users = User.paginate(page: params[:page])
  end
  def show
    @user = User.find(params[:id])
  end
  def new
    @user = User.new
  end
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Registration successful"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      if current_user?(@user)
        sign_in @user
        redirect_to @user
      else
        redirect_to users_path
      end
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end


  private

  def non_signed_in_user
    redirect_to(root_path) if signed_in?
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user) || current_user.admin?
  end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
