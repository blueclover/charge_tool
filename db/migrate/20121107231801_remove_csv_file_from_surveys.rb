class RemoveCsvFileFromSurveys < ActiveRecord::Migration
  def up
    remove_column :surveys, :csv_file
  end

  def down
    add_column :surveys, :csv_file, :string
  end
end
