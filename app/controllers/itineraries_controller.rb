class ItinerariesController < ApplicationController

  AMADEUS = Amadeus::Client.new({
    client_id: ENV['AMADEUS_TEST_KEY'],
    client_secret: ENV['AMADEUS_TEST_API_SECRET']
  })

  def search
  end

  def show
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
      originLocationCode: group[:location].city_code,
      destinationLocationCode: destination,
      departureDate: params["start_date"],
      returnDate: params["end_date"],
      adults: group[:adults],
      children: group[:children]
    }

    search = Search.find_by(search_criteria) || new_search(
      flights(amadeus_search_result(search_criteria), group, destination),
      search_criteria
    )
    search.flights
  end

  def new_search(flights, search_criteria)
    # adjust to handle a hash where flights are groups by itineraries and arriving/departing
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

  def amadeus_search_result(search_criteria)
    result = AMADEUS.shopping.flight_offers_search.get(search_criteria.merge({max: 10}))
    raise
    result.data
  end

  def flights(search_result, group, destination)
    # make the flights an array of hashes, where each hash is {
      # :going_there
      # :coming_back
      #}
    }
    flight_for_search = {}
    search_result.each do |result|
      result["itineraries"].each do |itinerary|
        result["segments"].each do |segment|
          flights_for_search << new_or_found_flight(segment, group, destination)
        end
      end
    end
  end

  def new_or_found_flight(segment, origin_location)
      Flight.find_by(
        flight_code: segment.map { |s| "#{s['carrierCode']} #{s['number']}" },
        departure_time: segment["departure"]["at"]
      ) || Flight.create(
        departure_time: segment["departure"]["at"],
        arrival_time: segment["arrival"]["at"],
        departure_airport: Airport.find_by_code(segment["departure"]["iataCode"]) || Airport.create(code: segment["departure"]["iataCode"], city: group["location"]),
        arrival_airport: Airport.find_by_code(segement["arrival"]["iataCode"]) || Airport.create(code: segment["arrival"]["iataCode"], city: Location.find_by_city_code(destination)),
        cost_per_head: flight["price"]["total"].to_f/flight["travelerPricings"].count,
        flight_code: segment.map { |s| "#{s['carrierCode']} #{s['number']}" }
      )
  end
end
