class AddHomeCityToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :home_city, :string
  end
end
