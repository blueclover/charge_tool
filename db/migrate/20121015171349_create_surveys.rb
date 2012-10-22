class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string :name
      t.integer :user_id

      t.timestamps
    end
    add_index :surveys, :user_id
  end
end
