class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.integer :charge_type

      t.timestamps
    end
  end
end
