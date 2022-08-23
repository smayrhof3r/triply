class DeleteHomeCityFromUsers < ActiveRecord::Migration[7.0]

  def change
    remove_column :users, :home_city, :string
  end
end
