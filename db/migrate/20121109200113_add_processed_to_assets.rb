class AddProcessedToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :processed, :boolean, default: false
  end
end
