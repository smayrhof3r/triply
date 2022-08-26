class CreateSearches < ActiveRecord::Migration[7.0]
  def change
    create_table :searches do |t|
      t.string :origin
      t.string :destination
      t.string :date
      t.string :adults
      t.string :children
      t.references :flights, null: false, foreign_key: true

      t.timestamps
    end
  end
end
