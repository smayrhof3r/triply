class RemoveNumberOfPassengersFromPassengerGroup < ActiveRecord::Migration[7.0]
  def change
    remove_column :passenger_groups, :number_of_passengers
  end
end
