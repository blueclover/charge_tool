class Booking < ActiveRecord::Base
  attr_accessible :booking_date, :zip_code, :city, :booking_details_attributes
  belongs_to :survey
  has_many :booking_details, dependent: :delete_all
  has_many :charges, through: :booking_details
  has_many :charge_types, through: :charges

  #before_save :commit_score!

  accepts_nested_attributes_for :booking_details, allow_destroy: true

  validates :survey_id, presence: true

  scope :relevant,    -> { where("score < ? AND score > ?", 16, 2) }
  scope :no_zip,      -> { where("zip_code <= ? OR zip_code >= ? OR zip_code IS NULL", '00000', '99999') }
  scope :with_zip,    -> { where("zip_code > ? AND zip_code < ?", '00000', '99999') }
  scope :with_ca_zip, -> { where("zip_code BETWEEN ? AND ?", '90001', '96162') }
  scope :zip,         ->(zip) { where("zip_code = ?", "#{zip}") }

  def commit_score!
    total_score = 0
    charges.each {|charge| total_score |= charge.score } # the | is bitwise OR
    self.score = total_score
  end

  def bucket
    if score.nil?
      commit_score!
      save!
    end
    s = score
    if s > 15
      "Disqualified"
    elsif s > 7
      "Relevant"
    else
      "Not Relevant"
    end
  end
end
