class Booking < ActiveRecord::Base
  attr_accessible :booking_date, :zip_code
  has_many :booking_details, dependent: :destroy
  has_many :charges, through: :booking_details

  def score
    score = 0
    charges.each {|charge| score |= charge.score } # the | is bitwise OR
    score
  end
end
