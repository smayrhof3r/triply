class RemoveFlightIdFromBookings < ActiveRecord::Migration[7.0]
  def change
    remove_reference :bookings, :flight, null: false, foreign_key: true
  end
end
