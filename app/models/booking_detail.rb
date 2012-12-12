class BookingDetail < ActiveRecord::Base
  attr_accessible :charge_id, :rank
  belongs_to :booking
  belongs_to :charge
  delegate :score, to: :charge

  #validates :booking_id, presence: true # this breaks the new booking form
  validates :charge_id, presence: true
  validates :rank, presence: true

  default_scope order: 'booking_id, rank'

  def category
    charge.charge_type.description || 'N/A'
  end

  def alias
    charge.charge_aliases.first.alias
  end
end
