class BookingsController < ApplicationController
  before_filter :signed_in_user
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
    redirect_to bookings_url
  end

  private
    def find_survey
      @survey = Survey.find(params[:survey_id])
    end
    def find_booking
      @booking = @survey.bookings.find(params[:id])
    end

end
