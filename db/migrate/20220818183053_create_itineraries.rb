class CreateItineraries < ActiveRecord::Migration[7.0]
  def change
    create_table :itineraries do |t|
      t.date :start_date
      t.date :end_date
      t.float :budget
      t.references :destination, index: true, foreign_key: { to_table: :locations }
      t.timestamps
    end
  end
end
