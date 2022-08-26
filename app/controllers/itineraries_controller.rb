class ItinerariesController < ApplicationController

  AMADEUS = Amadeus::Client.new({
    client_id: ENV['AMADEUS_TEST_KEY'],
    client_secret: ENV['AMADEUS_TEST_API_SECRET']
  })

  def search
  end

  def index

    count = params["passenger_group_count"].to_i

    # try each destination
    possible_destinations.each do |destination|
      valid_destination = true
      groups = (1..count).to_a.map { |i| passenger_group_params(i) }

      # find valid destinations and create itineraries
      groups.each do |group|

        # retrieve or find & save top flights
        group[:top_flights] = top_flights(group, destination)

        # skip to next destination if not all groups can fly there
        if group[:top_flights].empty?
          valid_destination = false
          break
        end
      end

      @itineraries << create_itinerary_and_bookings_for(groups) if valid_destination
    end
  end

  private

  def create_itinerary_and_bookings_for(groups)
    itinerary = Itinerary.new
    groups.each do |group|
      group[:top_flights].each_with_index do |flight, index|
        Booking.create(
          passenger_group: new_passenger_group(group, itinerary),
          flight: flight,
          status: index.zero? ? "suggested" : "alternative"
        )
      end
    end
    itinerary
  end

  def new_passenger_group(group, itinerary)
    p = PassengerGroup.new(group.transform_keys(location: :origin_city))
    p.itinerary = itinerary
    p.save
    p
  end

  def top_flights(group, destination)
    # collect top flights
    search_criteria = {
      originLocationCode: group["location"].city_code,
      destinationLocationCode: destination,
      departureDate: params["start_date"],
      adults: group["adults"],
      children: group["children"]
    }

    search = Search.find_by(search_criteria) || new_search(flights(amadeus_search_result), search_criteria)
    search.flights
  end

  def new_search(flights, search_criteria)
    search = Search.create(search_criteria)
    flights.each do |flight|
      SearchResult.create(search: search, flight: flight)
    end

    search
  end

  def possible_destinations
    # replace with logic to find matching destinations using the api endpoint if fixed
    # also need to then get the relevant unsplash images if not already in our database (see seed file)
    Search::DESTINATIONS
  end

  def passenger_group_params(i)
    # NOTE: requires form city to be a valid city from our database!
    adults = params["adults#{i}"]
    children = params["children#{i}"]
    location = Location.find_by_city(params["origin_city#{i}"])
    {
      adults: adults,
      children: children,
      location: location
    }
  end

  def amadeus_search_result
    AMADEUS.shopping.flight_offers_search.get(search_criteria.merge({max: 10})).data
  end

  def flights(search_result)
    search_result.map do |flight|
      Flight.find_by(
        flight_code: flight["itineraries"].first["segments"].map {|s| "#{s["carrierCode"]} #{s["number"]}"}.flatten,
        departure_time: flight["itineraries"].first["segments"].first["departure"]["at"]
      ) || Flight.create(
        departure_time: flight["itineraries"].first["segments"].first["departure"]["at"],
        arrival_time: flight["itineraries"].last["segments"].last["arrival"]["at"],
        departure_airport: Airport.find_by_code(flight["itineraries"].first["segments"].first["departure"]["iataCode"]) || Airport.create(code: flight["itineraries"].first["segments"].first["departure"]["iataCode"], city: group["location"]),
        arrival_airport: Airport.find_by_code(flight["itineraries"].last["segments"].last["arrival"]["iataCode"]),
        cost_per_head: flight["price"]["total"].to_f/flight["travelerPricings"].count,
        flight_code: flight["itineraries"].first["segments"].map {|s| "#{s["carrierCode"]} #{s["number"]}"}.flatten
      )
    end
  end
end
