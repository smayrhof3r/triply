class AddSearchResultsJsonToSearches < ActiveRecord::Migration[7.0]
  def change
    add_column :searches, :amadeus_response, :json, default: {}
  end
end
