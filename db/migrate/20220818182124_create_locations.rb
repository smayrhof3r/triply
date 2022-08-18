class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :city
      t.string :country
      t.string :region
      t.float :longitude
      t.float :latitude

      t.timestamps
    end
  end
end
