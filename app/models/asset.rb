class Asset < ActiveRecord::Base
  attr_accessible :asset

  belongs_to :survey

  default_scope order: 'assets.id'

  has_attached_file :asset, :path => (Rails.root + "files/:id").to_s,
                    :url => "/files/:id"

  def proper_headers?(user_settings)
    field_names = user_settings.booking_headers + user_settings.charge_headers

    required_fields = {}
    field_names.each do |field|
      required_fields[field] = 0
    end

    # open file and read just first line
    fields = CSV.parse(File.open(asset.path, &:readline))[0]

    fields.each do |field|
      required_fields[field] += 1 if required_fields.has_key?(field)
    end

    required_fields.each_value do |count|
      return false if count != 1
    end

    true
  end

  def process_data!(user_settings)
    db_field_names  = user_settings.required_fields
    csv_field_names = user_settings.booking_headers

    charge_headers = user_settings.charge_headers

    ActiveRecord::Base.establish_connection

    created_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")

    CSV.foreach(asset.path, {headers: :first_row}) do |row|
      sql_vals = []

      #booking_header_count.times do |idx|
      #  val = row[idx]
      #  sql_vals << ActiveRecord::Base.connection.quote(val)
      #end
      csv_field_names.each do |column|
        val = row[column]
        sql_vals << ActiveRecord::Base.connection.quote(val)
      end

      sql = "
            INSERT INTO bookings
              (survey_id, #{db_field_names.join(', ')}, created_at, updated_at)
            VALUES
              (#{survey_id}, #{sql_vals.join(', ')}, '#{created_at}', '#{created_at}')
            RETURNING id
          "

      booking_id = ActiveRecord::Base.connection.insert(sql)

      charge_headers.each_with_index do |column, i|
        val = row[column]
        if val.to_s.length > 0
          val = ActiveRecord::Base.connection.quote(val)

          sql = "
                INSERT INTO booking_details (booking_id, rank, charge_id, created_at, updated_at)
                SELECT #{booking_id}, #{i+1}, c.id, '#{created_at}', '#{created_at}'
                FROM charge_aliases a, charges c
                WHERE a.charge_id = c.id AND a.alias = #{val}
                RETURNING id
              "
          ActiveRecord::Base.connection.execute(sql)
        end
      end
    end
  end
end
