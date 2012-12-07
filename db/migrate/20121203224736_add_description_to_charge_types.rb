class AddDescriptionToChargeTypes < ActiveRecord::Migration
  def change
    add_column :charge_types, :description, :string
  end
end
