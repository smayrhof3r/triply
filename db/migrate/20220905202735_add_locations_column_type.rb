class AddLocationsColumnType < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :planet_money, :json, default: {}
  end
end
