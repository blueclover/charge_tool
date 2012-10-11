class CreateChargeTypes < ActiveRecord::Migration
  def change
    create_table :charge_types do |t|
      t.integer :score

      t.timestamps
    end
  end
end
