class RenameChargeTypeChargeTypeIdInCharges < ActiveRecord::Migration
  def change
    rename_column :charges, :charge_type, :charge_type_id
  end
end
