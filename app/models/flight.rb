class Flight < ApplicationRecord
  # has_many :airports

  # has_many :search_results
  # has_many :searches, through: :search_results

  def city(type)
    if type = "departure"
      Airport.find(departure_airport_id).location.city
    else
      Airport.find(arrival_airport_id).location.city
    end
  end
end
