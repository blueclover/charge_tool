class Charge < ActiveRecord::Base
  attr_accessible :charge_type_id

  belongs_to :charge_type
  delegate :score, to: :charge_type

  has_many :charge_aliases
  has_many :booking_details
  has_many :bookings, through: :booking_details

  validates :charge_type_id, presence: true
end
