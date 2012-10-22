class Booking < ActiveRecord::Base
  attr_accessible :booking_date, :zip_code, :booking_details_attributes
  belongs_to :survey
  has_many :booking_details, dependent: :destroy
  has_many :charges, through: :booking_details
  accepts_nested_attributes_for :booking_details, allow_destroy: true

  validates :survey_id, presence: true

  def score
    score = 0
    charges.each {|charge| score |= charge.score } # the | is bitwise OR
    score
  end

  def bucket
    s = score
    if s > 15
      "Disqualified"
    elsif s > 10
      "Co-Occurring"
    elsif s > 7
      "Substance Abuse"
    elsif s > 2
      "Mental Health"
    else
      "N/A"
    end
  end
end
