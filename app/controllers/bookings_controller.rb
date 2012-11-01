class BookingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_survey
  before_filter :find_booking, :only => [:show, :edit, :update, :destroy]

  def index
  end

  def show
  end

  def new
    @booking = @survey.bookings.build
  end

  def create
    @booking = @survey.bookings.build(params[:booking])
    if @booking.save
      flash[:success] = "Successfully created booking."
      redirect_to [@project, @booking]
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @booking.update_attributes(params[:booking])
      flash[:success] = "Successfully updated booking."
      redirect_to [@survey, @booking]
    else
      render :edit
    end
  end

  def destroy
    @booking.destroy
    flash[:success] = "Successfully destroyed booking."
    redirect_to survey_bookings_url(@survey)
  end

  private
    def find_survey
      @survey = Survey.for(current_user).find(params[:survey_id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The survey you were looking" +
          " for could not be found."
      redirect_to root_path
    end
    def find_booking
      @booking = @survey.bookings.find(params[:id])
    end

end
