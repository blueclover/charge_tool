class UserConfiguration < ActiveRecord::Base
  attr_accessible :booking_date_field_name, :zip_code_field_name, :city_field_name,
                  :state_field_name, :charge_field_prefix, :num_charges

  belongs_to :user

  validates :user_id, presence: true
  validates :charge_field_prefix,  presence: true, length: { maximum: 50 }
end
