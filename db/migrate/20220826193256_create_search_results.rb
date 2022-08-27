class CreateSearchResults < ActiveRecord::Migration[7.0]
  def change
    create_table :search_results do |t|
      t.references :search, null: false, foreign_key: true
      t.references :flight, null: false, foreign_key: true
      t.timestamps
    end
  end
end
