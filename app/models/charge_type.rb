class ChargeType < ActiveRecord::Base
  attr_accessible :score

  has_many :charges

  validates :score, presence: true
end
