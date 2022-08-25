class AddCityCodeToLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :city_code, :string
  end
end
