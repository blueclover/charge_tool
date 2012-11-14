class UserConfiguration < ActiveRecord::Base
  attr_accessible :booking_date_field_name, :zip_code_field_name, :city_field_name,
                  :state_field_name, :charge_field_prefix, :num_charges

  belongs_to :user

  validates :user_id, presence: true
  validates :charge_field_prefix,  presence: true, length: { maximum: 50 }

  def booking_fields
    ['booking_date', 'zip_code', 'city', 'state']
  end

  def booking_headers
    booking_headers = []

    required_fields.each do |field|
      booking_headers << self.send(field + '_field_name')
    end

    booking_headers
  end

  def required_fields
    required_fields = []

    booking_fields.each do |field|
      required_fields << field unless self.send(field + '_field_name').empty?
    end

    required_fields
  end

  def charge_headers
    charge_headers = []

    1.upto(num_charges) do |n|
      charge_headers << "#{charge_field_prefix}#{n}"
    end

    charge_headers
  end
end
