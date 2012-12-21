class BookingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_survey
  before_filter :find_booking, :only => [:show, :edit, :update, :destroy]

  SCOPES = %w{no_zip with_zip with_ca_zip}
  COLUMNS = %w{id city score zip_code}

  def index
    @filter = params[:filter] || nil
    @sort = params[:sort]
    @sort = 'score' unless COLUMNS.include?(@sort)

    if @filter == 'relevant'
      @bookings = @survey.bookings.relevant
    elsif SCOPES.include?(@filter)
      @bookings = @survey.bookings.relevant.send(@filter)
    else
      @bookings = @survey.bookings
    end
    @bookings = @bookings.order(@sort).paginate(page: params[:page], per_page: 100)
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
      redirect_to [@survey, @booking]
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
