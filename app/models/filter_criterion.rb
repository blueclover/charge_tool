class FilterCriterion < ActiveRecord::Base
  attr_accessible :charge_type_id, :significance
  belongs_to :survey
  belongs_to :charge_type

  #validates :survey_id, presence: true
  validates :charge_type_id, presence: true
  validates :significance, presence: true

  delegate :description, to: :charge_type
end
