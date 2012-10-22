class AddCsvFileToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :csv_file, :string
  end
end
