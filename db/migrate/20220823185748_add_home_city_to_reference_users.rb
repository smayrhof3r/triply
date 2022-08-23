class AddHomeCityToReferenceUsers < ActiveRecord::Migration[7.0]
  def change
    change_table :users do |t|
      t.references :home_city, index: true, foreign_key: { to_table: :locations }
    end
  end
end
