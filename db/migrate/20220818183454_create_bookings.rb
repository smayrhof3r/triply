class CreateBookings < ActiveRecord::Migration[7.0]
  def change
    create_table :bookings do |t|
      t.references :passenger_group, null: false, foreign_key: true
      t.references :flight, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
