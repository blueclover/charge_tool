class ChargeType < ActiveRecord::Base
  attr_accessible :score, :description

  has_many :charges

  validates :score, presence: true
end
