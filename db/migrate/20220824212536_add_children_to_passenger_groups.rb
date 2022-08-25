class AddChildrenToPassengerGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :passenger_groups, :children, :integer
  end
end
