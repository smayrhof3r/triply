class RemoveSearchResultFromBooking < ActiveRecord::Migration[7.0]
  def change
    remove_column :bookings, :search_result_id
  end
end
