class CreatePassengerGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :passenger_groups do |t|
      t.integer :number_of_passengers
      t.references :itinerary, null: false, foreign_key: true
      t.references :origin_city, index: true, foreign_key: { to_table: :locations }
      t.timestamps
    end
  end
end
