class BookingDetail < ActiveRecord::Base
  attr_accessible :charge_id, :rank
  belongs_to :booking
  belongs_to :charge
  delegate :score, to: :charge

  validates :booking_id, presence: true
  validates :charge_id, presence: true
  validates :rank, presence: true

  default_scope order: 'booking_id, rank'
end
