class Survey < ActiveRecord::Base
  attr_accessible :name, :assets_attributes
  belongs_to  :user

  before_destroy :delete_booking_details!
  has_many :bookings, dependent: :delete_all

  has_many :assets, dependent: :destroy
  has_many :permissions, :as => :thing, dependent: :delete_all

  validates :name, presence: true, length: { maximum: 50 }
  validates :user_id, presence: true

  accepts_nested_attributes_for :assets

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
    bookings.each.save
  end

  def delete_booking_details!
    sql = "DELETE FROM booking_details " +
          "USING bookings " +
          "WHERE bookings.id = booking_details.booking_id " +
          "AND bookings.survey_id = #{self.id}"
    ActiveRecord::Base.connection.execute(sql)
  end
end
