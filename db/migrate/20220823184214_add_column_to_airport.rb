class AddColumnToAirport < ActiveRecord::Migration[7.0]
  def change
    add_column :airports, :code, :string
  end
end
