class CreateBookingDetails < ActiveRecord::Migration
  def change
    create_table :booking_details do |t|
      t.integer :booking_id
      t.integer :rank
      t.integer :charge_id

      t.timestamps
    end
    add_index :booking_details, [:booking_id, :rank], unique: true
  end
end
