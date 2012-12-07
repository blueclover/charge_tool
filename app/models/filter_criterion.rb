class FilterCriterion < ActiveRecord::Base
  attr_accessible :charge_type_id, :significance
  belongs_to :survey
  #validates :survey_id, presence: true
  validates :charge_type_id, presence: true
  validates :significance, presence: true
end
