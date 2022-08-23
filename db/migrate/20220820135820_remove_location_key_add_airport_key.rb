class RemoveLocationKeyAddAirportKey < ActiveRecord::Migration[7.0]
  def change 
    change_table :flights do |t|
      t.remove :departure_city_id, :arrival_city_id, :departure_airport, :arrival_airport
    end
  end
end
