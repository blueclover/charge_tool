class CreateFilterCriteria < ActiveRecord::Migration
  def change
    create_table :filter_criteria do |t|
      t.integer :survey_id
      t.integer :charge_type_id
      t.integer :significance

      t.timestamps
    end

    add_index :filter_criteria, :survey_id
    add_index :filter_criteria, [:survey_id, :charge_type_id], unique: true
  end
end
