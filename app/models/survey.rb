class Survey < ActiveRecord::Base
  attr_accessible :name, :assets_attributes, :filter_criteria_attributes
  belongs_to  :user

  before_destroy :delete_booking_details!
  has_many :bookings, dependent: :delete_all

  has_many :filter_criteria, dependent: :delete_all
  accepts_nested_attributes_for :filter_criteria

  has_many :assets, dependent: :destroy
  accepts_nested_attributes_for :assets

  has_many :permissions, :as => :thing, dependent: :delete_all

  validates :name, presence: true, length: { maximum: 50 }
  validates :user_id, presence: true


  default_scope order: 'surveys.created_at DESC'

  def self.viewable_by(user)
    #join = "LEFT JOIN permissions ON permissions.thing_id = surveys.id " +
    #       "AND permissions.thing_type = 'Survey'"
    #where = "(permissions.action = 'view' " +
    #        "AND permissions.user_id = ?) OR surveys.user_id = ?"
    #joins(join).where(where, user.id, user.id)
    #joins(:permissions).where(:permissions => { :action => "view",
    #                                            :user_id => user.id })
    where(user_id: user.id)
  end

  def self.for(user)
    user.admin? ? Survey : Survey.viewable_by(user)
  end

  def commit_scores!
    set_filter_criteria!
    clear_scores!
    update_booking_scores!(-1, 16)
    update_booking_scores!(1, 8)
    set_null_scores_to_zero!
  end

  def set_filter_criteria!
    unless filter_criteria.exists?
      created_at = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      sql = "INSERT INTO filter_criteria
              (survey_id, charge_type_id, significance, created_at, updated_at)
               SELECT #{self.id}, charge_type_id, significance,
              '#{created_at}', '#{created_at}'
               FROM filter_criteria
               WHERE survey_id = 0
        "
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  def update_booking_scores!(significance, score)
    sql = "UPDATE bookings b
              SET score = #{score}
              FROM booking_details bd, charges c, filter_criteria fc
              WHERE b.id = bd.booking_id AND bd.charge_id = c.id
              AND b.survey_id = fc.survey_id AND c.charge_type_id = fc.charge_type_id
              AND score IS NULL
              AND b.survey_id = #{self.id}
              AND fc.significance = #{significance}
    "
    ActiveRecord::Base.connection.execute(sql)
  end

  def clear_scores!
    sql = "UPDATE bookings b
              SET score = null
              WHERE survey_id = #{self.id}
      "
    ActiveRecord::Base.connection.execute(sql)
  end

  def set_null_scores_to_zero!
    sql = "UPDATE bookings b
              SET score = 0
              WHERE survey_id = #{self.id} AND b.score IS NULL
      "
    ActiveRecord::Base.connection.execute(sql)
  end

  def charge_type_table
    bookings.joins(:charge_types).where('description IS NOT NULL').count(group: 'description' , order: 'description')
  end

  def frequency_table(column)
    table = bookings.count(group: column, order: "count(*) DESC")
  end

  def to_csv(column)
    table = frequency_table(column)
    CSV.generate do |csv|
      csv << [column, "count"]
      table.each do |key, value|
        csv << [key, value]
      end
    end
  end

  def delete_booking_details!
    sql = "DELETE FROM booking_details " +
          "USING bookings " +
          "WHERE bookings.id = booking_details.booking_id " +
          "AND bookings.survey_id = #{self.id}"
    ActiveRecord::Base.connection.execute(sql)
  end
end
