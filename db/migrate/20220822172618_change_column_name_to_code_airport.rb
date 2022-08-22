class ChangeColumnNameToCodeAirport < ActiveRecord::Migration[7.0]
  def change
    rename_column :airports, :name, :code
  end
end
