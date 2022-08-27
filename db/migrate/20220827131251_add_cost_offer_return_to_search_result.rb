class AddCostOfferReturnToSearchResult < ActiveRecord::Migration[7.0]
  def change
    add_column :search_results, :return_flight, :boolean
    add_column :search_results, :cost_per_head, :float
    add_column :search_results, :offer_index, :integer
  end
end
