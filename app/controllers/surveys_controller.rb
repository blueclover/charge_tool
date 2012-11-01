class SurveysController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_survey, only: [:show, :edit, :update, :destroy, :upload]

  def index
    @surveys = Survey.for(current_user).paginate(page: params[:page])
  end
  def show
  end
  def new
    @survey = Survey.new
  end

  def create
    @survey = current_user.surveys.build(params[:survey])
    if @survey.save
      flash[:success] = "Survey created!"
      redirect_to upload_survey_path(@survey)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @survey.update_attributes(params[:survey])
      if params[:survey][:csv_file] && @survey.csv_file.to_s  =~ /\.csv\Z/
        process_data!("#{@survey.csv_file.to_s}"[1..-1],@survey.id)
        #@survey.remove_csv_file = true
        #@survey.save
        flash[:success] = "File processed"
      else
        flash[:success] = "Survey updated"
      end
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
  end

  def process_data!(file, survey_id)
    # booking_header_count = 2
    charge_header_count = 5

    booking_headers = [
        "zip_code",
        "booking_date"
    ]

    charge_headers = []
    1.upto(charge_header_count) { |i| charge_headers << "charge_#{i}" }

    ActiveRecord::Base.establish_connection

    created_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    CSV.foreach(file, {headers: :first_row}) do |row|
      sql_vals = []

      #booking_header_count.times do |idx|
      #  val = row[idx]
      #  sql_vals << ActiveRecord::Base.connection.quote(val)
      #end
      booking_headers.each do |column|
        val = row[column]
        sql_vals << ActiveRecord::Base.connection.quote(val)
      end

      sql = "
        INSERT INTO bookings
          (survey_id, #{booking_headers.join(', ')}, created_at, updated_at)
        VALUES
          (#{survey_id}, #{sql_vals.join(', ')}, '#{created_at}', '#{created_at}')
        RETURNING id
      "

      booking_id = ActiveRecord::Base.connection.insert(sql)

      rank = 1
      #booking_header_count.upto(last_index) do |idx|
      #  val = row[idx]
      charge_headers.each do |column|
        val = row[column]
        if val.to_s.length > 0
          val = ActiveRecord::Base.connection.quote(val)

          sql = "
            INSERT INTO booking_details (booking_id, rank, charge_id, created_at, updated_at)
            SELECT #{booking_id}, #{rank}, c.id, '#{created_at}', '#{created_at}'
            FROM charge_aliases a, charges c
            WHERE a.charge_id = c.id AND a.alias = #{val}
            RETURNING id
          "
          ActiveRecord::Base.connection.execute(sql)
          rank += 1
        end
      end
    end

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