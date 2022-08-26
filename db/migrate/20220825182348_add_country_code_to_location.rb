class AddCountryCodeToLocation < ActiveRecord::Migration[7.0]
  def change
    add_column :locations, :country_code, :string
  end
end
