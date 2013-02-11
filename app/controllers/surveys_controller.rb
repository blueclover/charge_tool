class SurveysController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_survey,
                only: [:show, :edit, :update, :destroy, :frequency_table, :commit_scores]

  def index
    @surveys = Survey.for(current_user).paginate(page: params[:page])
  end
  def show
    @charge_table = @survey.charge_type_table
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
      proper_headers = true
      @survey.assets.each do |asset|
        unless asset.proper_headers?(current_user.settings)
          proper_headers = false
          flash[:error] = "#{asset.asset_file_name} does not have proper headers. Please modify settings below or change column headers in the file."
          break
        end
      end

      if proper_headers
        @survey.assets.each do |asset|
            asset.process_data!(current_user.settings)
        end
        @survey.commit_scores!
        flash[:success] = "Survey created"
        redirect_to @survey
      else
        @survey.destroy
        redirect_to settings_path
      end
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @survey.update_attributes(params[:survey])
      @survey.commit_scores!
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

  def frequency_table
    @column = params[:column]
    @sort = params[:sort]
    @order = params[:order]

    @column = 'zip_code' unless ['city', 'zip_code'].include?(@column)

    sort = @column

    if @sort == 'freq'
      sort = 'count(*)'
    end

    sort += " #{@order}"

    # if @order == 'desc'
    #   sort += ' DESC'
    # end

    @table = @survey.frequency_table(@column, sort)

    respond_to do |format|
      format.html
      format.csv { send_data @survey.to_csv(@column, sort) }
    end
  end

  def commit_scores
    t = Time.now
    @survey.commit_scores!
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
end