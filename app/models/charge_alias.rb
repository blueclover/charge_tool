class ChargeAlias < ActiveRecord::Base
  attr_accessible :alias, :charge_id

  belongs_to :charge
  delegate :score, to: :charge

  validates :alias, presence: true
  validates :charge_id, presence: true
end
