class RenamePlanetMoneyToLonelyPlanet < ActiveRecord::Migration[7.0]
  def change
    rename_column :locations, :planet_money, :lonely_planet
  end
end
