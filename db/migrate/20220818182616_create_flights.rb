class CreateFlights < ActiveRecord::Migration[7.0]
  def change
    create_table :flights do |t|
      t.references :departure_city, index: true, foreign_key: { to_table: :locations }
      t.references :arrival_city, index: true, foreign_key: { to_table: :locations }
      t.datetime :departure_time
      t.datetime :arrival_time
      t.string :departure_airport
      t.string :arrival_airport
      t.float :cost_per_head
      t.string :flight_code

      t.timestamps
    end
  end
end
