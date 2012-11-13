class FilesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_asset, only: [:show, :edit, :update, :destroy, :process_csv]

  def show
    send_file @asset.asset.path,
              :filename => @asset.asset_file_name,
              :content_type => @asset.asset_content_type
  end

  def new
    @survey = Survey.new
    asset = @survey.assets.build
    render partial: "files/form",
           locals: { number: params[:number].to_i,
           asset: asset}
  end

  def edit
  end

  def update
  end

  def destroy
    if current_user.admin? || @survey.user == current_user
      @asset.destroy
      flash[:notice] = "File has been deleted."
    else
      flash[:alert] = "You cannot delete a file created by another user."
    end

    redirect_to @survey
  end

  def process_csv
    if proper_headers?(@asset.asset.path)
      flash[:success] = "File has proper headers."
    else
      flash[:alert] = "File does not have proper headers."
    end

    redirect_to @survey
  end

  def proper_headers?(file_path)
    user_settings = UserConfiguration.find_by_user_id(current_user.id)

    required_fields = {}
    ['booking_date', 'zip_code', 'city', 'state'].each do |field|
      custom_name = user_settings.send(field + '_field_name')
      required_fields[custom_name] = 0 unless custom_name.empty?
    end

    prefix = user_settings.charge_field_prefix

    user_settings.num_charges.times do |n|
      required_fields["#{prefix}#{n+1}"] = 0
    end

    # open file and read just first line
    fields = CSV.parse(File.open(file_path, &:readline))[0]

    fields.each do |field|
      required_fields[field] += 1 if required_fields.has_key?(field)
    end

    required_fields.each_value do |count|
      return false if count != 1
    end

    true
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
    def find_asset
      @asset = Asset.find(params[:id])
      @survey = Survey.for(current_user).find(@asset.survey)
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The file you were looking" +
          " for could not be found."
      redirect_to root_path
    end
end
