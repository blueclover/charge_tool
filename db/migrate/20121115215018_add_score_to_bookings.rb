class AddScoreToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :score, :integer

    add_index :bookings, :score
  end
end
