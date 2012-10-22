class Survey < ActiveRecord::Base
  attr_accessible :name, :csv_file, :remove_csv_file
  belongs_to  :user
  has_many :bookings, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :user_id, presence: true

  default_scope order: 'surveys.created_at DESC'

  mount_uploader :csv_file, CsvUploader
end
