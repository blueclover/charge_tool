class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.string :zip_code
      t.date :booking_date

      t.timestamps
    end
    add_index :bookings, :zip_code
  end
end
