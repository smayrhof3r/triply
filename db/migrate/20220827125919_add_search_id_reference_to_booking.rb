class AddSearchIdReferenceToBooking < ActiveRecord::Migration[7.0]
  def change
    add_reference :bookings, :search_result, index: true
  end
end
