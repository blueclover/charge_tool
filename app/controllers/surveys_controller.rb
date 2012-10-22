class SurveysController < ApplicationController
  before_filter :signed_in_user

  def show
    @survey = Survey.find(params[:id])
  end
  def new
    @survey = Survey.new
  end

  def create
    @survey = current_user.surveys.build(params[:survey])
    if @survey.save
      flash[:success] = "Survey created!"
      redirect_to edit_survey_path(@survey)
    else
      render :new
    end
  end

  def edit
    @survey = Survey.find(params[:id])
  end

  def update
    @survey = Survey.find(params[:id])
    if @survey.update_attributes(params[:survey])
      if @survey.csv_file.to_s  =~ /\.csv\Z/
        process_data!("public/#{@survey.csv_file.to_s}",@survey.id)
      else
        flash[:success] = "Survey updated"
      end
      redirect_to @survey
    else
      render 'edit'
    end
  end

  def destroy
  end

  def process_data!(file, survey_id)
    booking_header_count = 2
    charge_header_count = 5
    last_index = booking_header_count + charge_header_count - 1

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
          detail_id = ActiveRecord::Base.connection.execute(sql)
          rank += 1
        else

        end
      end


      #booking_id = ActiveRecord::Base.connection.last_inserted_id(res)

      # do some cool stuff, like create records in other tables that reference bar_id
      # use ActiveRecord::Base.connection.execute(your_sql) in subsequent calls.
      # no need to close the connection, or reopen it before calling execute.
    end

  end
end