class SurveysController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_survey, only: [:show, :edit, :update, :destroy, :upload]

  def index
    @surveys = Survey.for(current_user).paginate(page: params[:page])
  end
  def show
  end
  def new
    @survey = current_user.surveys.build
    @survey.assets.build
  end

  def create
    @survey = current_user.surveys.build(params[:survey])
    if @survey.save
      flash[:success] = "Survey created"
      redirect_to @survey
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @survey.update_attributes(params[:survey])
      flash[:success] = "Survey updated"
      redirect_to @survey
    else
      render 'edit'
    end
  end

  def destroy
    if current_user.admin? || @survey.user == current_user
      @survey.destroy
      flash[:notice] = "Survey has been deleted."
    else
      flash[:alert] = "You cannot delete a survey created by another user."
    end

    redirect_to surveys_path
  end

  def upload
    @survey.assets.build
  end

  private
    def find_survey
      @survey = Survey.for(current_user).find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The survey you were looking" +
          " for could not be found."
      redirect_to root_path
    end
end