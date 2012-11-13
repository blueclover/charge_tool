class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.string :asset_file_name
      t.integer :asset_file_size
      t.string :asset_content_type
      t.datetime :asset_updated_at
      t.integer :survey_id
      t.timestamps
    end
    add_index :assets, :survey_id
  end
end
