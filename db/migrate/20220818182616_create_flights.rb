class CreateFlights < ActiveRecord::Migration[7.0]
  def change
    create_table :flights do |t|
      t.datetime :departure_time
      t.datetime :arrival_time
      t.references :departure_airport, index: true, foreign_key: { to_table: :airports}
      t.references :arrival_airport, index: true, foreign_key: { to_table: :airports}
      t.float :cost_per_head
      t.string :flight_code

      t.timestamps
    end
  end
end
