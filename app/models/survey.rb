class Survey < ActiveRecord::Base
  attr_accessible :name, :csv_file, :remove_csv_file
  belongs_to  :user
  has_many :bookings, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :user_id, presence: true

  has_many :permissions, :as => :thing, dependent: :delete_all

  default_scope order: 'surveys.created_at DESC'

  mount_uploader :csv_file, CsvUploader

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
end
