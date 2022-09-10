class AddOffersJsonToBooking < ActiveRecord::Migration[7.0]
  def change
    add_column :bookings, :offer, :json, default: {}
  end
end
