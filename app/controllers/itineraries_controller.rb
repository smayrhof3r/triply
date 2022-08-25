class ItinerariesController < ApplicationController
  def search
  end

  def index
    @p = params
    @count = params["passenger_group_count"].to_i
    cities = origin_cities

    @starting_airports = Airport.all.filter do |airport|
      cities.include? airport.location.city.upcase
    end

    # passengers = createPassengerGroups
  end


  private

  def origin_cities
    (1..@count).to_a.map do |i|
      params["origin_city#{i}"].upcase
    end
  end

  # def createPassengerGroups
  #   (1..params["passenger_group_count"]).to_a.each do |count|
  #     location = Location.find_by_city(params["origin_city#{count}"])
  #     if location
  #       PassengerGroup.new({
  #         origin_city: location
  #         number_of_passengers:
  #       })
  #     end

  #   end
  # end
end
