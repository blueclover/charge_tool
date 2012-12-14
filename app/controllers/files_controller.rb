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
    if @asset.proper_headers?(current_user.settings)
      t = Time.now
      @asset.process_data!(current_user.settings)
      t = Time.now - t
      flash[:success] = "File processed in #{t} seconds."
    else
      flash[:alert] = "File does not have proper headers."
    end

    redirect_to @survey
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

    def process_data_QUICK!(file_path, survey_id)
      user_settings = current_user.settings

      db_field_names  = user_settings.required_fields
      csv_field_names = user_settings.booking_headers

      charge_headers = user_settings.charge_headers

      ActiveRecord::Base.establish_connection

      created_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")

      CSV.foreach(file_path, {headers: :first_row}) do |row|
        sql_vals = []

        csv_field_names.each do |column|
          val = row[column].strip
          sql_vals << ActiveRecord::Base.connection.quote(val)
        end

        score = 0

        charge_headers.each do |column|
          val = row[column].strip
          unless val.empty?
            val = ActiveRecord::Base.connection.quote(val)

            sql = "SELECT c.charge_type_id FROM charge_aliases a, charges c WHERE a.charge_id = c.id AND a.alias = #{val}"
            #sql = "SELECT t.score FROM charge_aliases a, charges c, charge_types t WHERE a.charge_id = c.id AND c.charge_type_id = t.id AND a.alias = #{val}"

            result = ActiveRecord::Base.connection.select_all(sql).first

            charge_type_id = result['charge_type_id'].to_i unless result.nil?

            if charge_type_id == 5
              score = 16
              break
            elsif charge_type_id == 2
              score = 8
            end
          end
        end

        sql = "
            INSERT INTO bookings
              (survey_id, #{db_field_names.join(', ')}, score, created_at, updated_at)
            VALUES
              (#{survey_id}, #{sql_vals.join(', ')}, #{score}, '#{created_at}', '#{created_at}')
            RETURNING id
          "

        ActiveRecord::Base.connection.insert(sql)
      end
    end
end
