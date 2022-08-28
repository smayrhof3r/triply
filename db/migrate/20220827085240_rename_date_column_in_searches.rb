class RenameDateColumnInSearches < ActiveRecord::Migration[7.0]
  def change
    rename_column(:searches, :date, :departureDate)
  end
end
