class AddAdultsToPassengerGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :passenger_groups, :adults, :integer
  end
end
