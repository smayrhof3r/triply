class CreateAirports < ActiveRecord::Migration[7.0]
  def change
    create_table :airports do |t|
      t.references :location, null: false, foreign_key: true
      t.string :name
      
      t.timestamps
    end
  end
end
