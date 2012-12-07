class SurveysController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_survey,
                only: [:show, :edit, :update, :destroy, :upload, :commit_scores]

  def index
    @surveys = Survey.for(current_user).paginate(page: params[:page])
  end
  def show
  end
  def new
    @survey = current_user.surveys.build
    @survey.assets.build
    #@survey.filter_criteria.build
    ChargeType.where('description IS NOT NULL').each do |type|
      @survey.filter_criteria.build(charge_type_id: type.id)
    end
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

  def commit_scores
    set_filter_criteria!

    t = Time.now
    set_all_scores_to_null!
    update_booking_scores!(-1, 16)
    update_booking_scores!(1, 8)
    set_null_scores_to_zero!
    t = Time.now - t
    flash[:success] = "Survey processed in #{t} seconds."
    redirect_to @survey
  end

  private
    def find_survey
      @survey = Survey.for(current_user).find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The survey you were looking" +
          " for could not be found."
      redirect_to root_path
    end

    def update_booking_scores!(significance, score)
      sql = "UPDATE bookings b
              SET score = #{score}
              FROM booking_details bd, charges c, filter_criteria fc
              WHERE b.id = bd.booking_id AND bd.charge_id = c.id
              AND b.survey_id = fc.survey_id AND c.charge_type_id = fc.charge_type_id
              AND score IS NULL
              AND b.survey_id = #{@survey.id}
              AND fc.significance = #{significance}
              "
      ActiveRecord::Base.connection.execute(sql)
    end

  def set_all_scores_to_null!
    sql = "UPDATE bookings b
              SET score = null
      "
    ActiveRecord::Base.connection.execute(sql)
  end

  def set_null_scores_to_zero!
    sql = "UPDATE bookings b
              SET score = 0
              WHERE survey_id = #{@survey.id} AND b.score IS NULL
      "
    ActiveRecord::Base.connection.execute(sql)
  end

    def set_filter_criteria!
      unless @survey.filter_criteria.exists?
        created_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")
        sql = "INSERT INTO filter_criteria
              (survey_id, charge_type_id, significance, created_at, updated_at)
               SELECT #{@survey.id}, charge_type_id, significance,
              '#{created_at}', '#{created_at}'
               FROM filter_criteria
               WHERE survey_id = 0
        "
        ActiveRecord::Base.connection.execute(sql)
      end
    end
end