class CreateChargeAliases < ActiveRecord::Migration
  def change
    create_table :charge_aliases do |t|
      t.string :alias
      t.integer :charge_id

      t.timestamps
    end
    add_index :charge_aliases, :alias, unique: true
  end
end
