class RemoveCostFromFlight < ActiveRecord::Migration[7.0]
  def change
    remove_column :flights, :cost_per_head
  end
end
