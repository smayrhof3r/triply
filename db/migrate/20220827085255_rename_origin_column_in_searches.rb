class RenameOriginColumnInSearches < ActiveRecord::Migration[7.0]
  def change
    rename_column(:searches, :origin, :originLocationCode)
  end
end
