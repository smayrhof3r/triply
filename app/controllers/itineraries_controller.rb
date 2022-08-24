class ItinerariesController < ApplicationController
  def search
  end

  def index
    @p = params

    # passengers = createPassengerGroups
  end


  # private

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
