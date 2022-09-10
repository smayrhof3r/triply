class CreateAirlines < ActiveRecord::Migration[7.0]
  def change
    create_table :airlines do |t|
      t.string :name
      t.string :iata_code

      t.timestamps
    end
  end
end
