class AddAirportKey < ActiveRecord::Migration[7.0]
  def change
    change_table :flights do |t|
      t.references :departure_airport, index: true, foreign_key: { to_table: :locations }
      t.references :arrival_airport, index: true, foreign_key: { to_table: :locations }
    end
  end
end
