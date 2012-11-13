class AddCityToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :city, :string
    add_column :bookings, :state, :string

    add_index :bookings, :city
    add_index :bookings, :state
  end
end
