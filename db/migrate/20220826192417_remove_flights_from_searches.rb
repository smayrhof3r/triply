class RemoveFlightsFromSearches < ActiveRecord::Migration[7.0]
  def change
    remove_reference :searches, :flights, index: true, foreign_key: true
  end
end
