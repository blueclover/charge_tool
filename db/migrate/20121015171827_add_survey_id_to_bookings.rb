class AddSurveyIdToBookings < ActiveRecord::Migration
  def change
    add_column :bookings, :survey_id, :integer
    add_index :bookings, :survey_id
  end
end
