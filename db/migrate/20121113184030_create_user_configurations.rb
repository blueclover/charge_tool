class CreateUserConfigurations < ActiveRecord::Migration
  def change
    create_table :user_configurations do |t|
      t.integer :user_id
      t.string :booking_date_field_name, default: 'booking_date'
      t.string :zip_code_field_name, default: 'zip_code'
      t.string :city_field_name, default: 'city'
      t.string :state_field_name, default: 'state'
      t.string :charge_field_prefix, default: 'charge_'
      t.integer :num_charges, default: 5
      t.timestamps
    end
    add_index :user_configurations, :user_id, unique: true
  end
end
