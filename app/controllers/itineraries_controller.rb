class ItinerariesController < ApplicationController

  @amadeus = Amadeus::Client.new({
    client_id: ENV['AMADEUS_TEST_KEY'],
    client_secret: ENV['AMADEUS_TEST_API_SECRET']
  })

  def search
  end

  def index

      count = params["passenger_group_count"].to_i

      # currently a fixed list; if flight destinations endpoint is fixed, we can find destinations that work for all origin cities
      @destinations = possible_destinations

      # pasenger group info
      @groups = (1..count).to_a.map { |i| passenger_group_params(i) }

      # create Itineraries
      @destinations.each do |destination|
        valid_destination = true
        # for each passenger group
        @flights = []
        @groups.each do |group|
        # create 5 flights (keep 5 cheapest options); don't save yet!
          group[:top_flights] = top_flights(group)
          if group[:top_flights].empty?
            valid_destination = false
            break
          end
        end

        if valid_destination
          i = Itinerary.new
          @groups.each do |group|
            p = PassengerGroup.create(
              origin_city: group[:location],
              adults: group[:adults],
              children: group[:children]
            )
          end
          # create itinerary
          # create passenger groups
          # create bookings (status: 'proposed')
        end

      end
      @flight_details.each do |flight|

        flight[:destinations] = amadeus.shopping.flight_offers_search.get(
          originLocationCode: flight[:origin],
          departureDate: params["start_date"],
          adults: flight[:adults],
          children: flight[:children]
        )
      end


      # passengers = createPassengerGroups

  end


  private

  def top_flights(group = {})

  end

  def possible_destinations
    # replace with logic to find matching destinations using the api endpoint if fixed
    @cities = File.readlines('cities.txt')
    @cities.map { |city| city.first(3) }
  end

  def passenger_group_params(i)
      adults = params["adults#{i}"]
      children = params["children#{i}"]
      location = Location.find_by_city(params["origin_city#{i}"])
      {
        adults: adults,
        children: children,
        location_id: location.id
      }
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
