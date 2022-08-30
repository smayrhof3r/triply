class RenameDestinationColumnInSearches < ActiveRecord::Migration[7.0]
  def change
    rename_column(:searches, :destination, :destinationLocationCode)
  end
end
