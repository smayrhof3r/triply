class ItinerariesController < ApplicationController
  before_action :update_session_url, only: [:search, :index]

  AMADEUS = Amadeus::Client.new({
    client_id: ENV['AMADEUS_TEST_KEY'],
    client_secret: ENV['AMADEUS_TEST_API_SECRET']
  })

  def search
  end

  def show
  end

  def index
    if session[:params] == params
      @itineraries = session[:itineraries].map { |i| Itinerary.find(i) }
      @re_used = true
    else
      @re_used = false
      @itineraries = []
      count = params["passenger_group_count"].to_i

      # try each destination
      possible_destinations.each do |destination|

        valid_destination = true
        groups = (1..count).to_a.map { |i| passenger_group_params(i) }

        next if groups.map { |g| g[:location].city_code }.include?(destination)

        # find valid destinations and create itineraries
        groups.each do |group|
          # retrieve or find & save top flights
          group[:search] = top_search_results(group, destination)

          # skip to next destination if not all groups can fly there
          if group[:search].search_results.empty?
            valid_destination = false
            break
          end
        end

        @itineraries << create_itinerary_and_bookings_for(groups, Location.find_by_city_code(destination)) if valid_destination
      end
      @itineraries.sort! {|a,b| a.total_cost <=> b.total_cost}
      @loc =  @itineraries.map do |itinerary|
        Location.find(itinerary.destination_id)
      end
      update_session_variables
    end
  end

  private

  def update_session_url
    session[:previous_request_url] = session[:current_request_url]
    session[:current_request_url] = request.url
  end

  def update_session_variables
    # should be able to destroy underlying models by destroying itineraries, but not working so we nest in
    delete_itineraries if session[:itineraries]

    session[:itineraries] = @itineraries.map(&:id)
    session[:params] = params
  end

  def delete_itineraries
    session[:itineraries].each do |i|
      itinerary = Itinerary.find_by(id: i)
      if itinerary
        itinerary.passenger_groups.each do |p|
          p.bookings.each do |b|
            b.delete
          end
          p.delete
        end
        itinerary.delete
      end
    end
  end

  def create_itinerary_and_bookings_for(groups, destination)
    # for each destination we only create ONE itinerary and set of passenger groups but MANY bookings
    itinerary = Itinerary.create(destination_id: destination.id, start_date: params["start_date"], end_date: params["end_date"])
    groups.each do |group|
      passenger_group = new_passenger_group(group, itinerary)
      min_offer_index = group[:search].search_results.map(&:offer_index).min
      group[:search].search_results.each do |search_result, index|
        Booking.create(
          passenger_group: passenger_group,
          search_result_id: search_result.id,
          status: search_result[:offer_index] == min_offer_index ? "suggested" : "alternative"
        )
      end
    end

    itinerary
  end

  def new_passenger_group(group, itinerary)

    p = PassengerGroup.new(group.except(:location, :search))
    p.itinerary = itinerary
    p.save
    p
  end

  def top_search_results(group, destination)
    # collect top flights
    @search_criteria = {
      originLocationCode: group[:location].city_code,
      destinationLocationCode: destination,
      departureDate: params["start_date"],
      returnDate: params["end_date"],
      adults: group[:adults],
      children: group[:children]
    }


    search = Search.find_by(@search_criteria) || new_search(
      amadeus_search_result, group, destination)

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
      location: location,
      origin_city_id: location.id
    }
  end

  def amadeus_search_result

    # result = AMADEUS.shopping.flight_offers_search.get(@search_criteria.merge({max: 10}))
    # result.data
    SearchHelper::AMADEUS_SAMPLE[@search_criteria["originLocationCode"]] || AMADEUS.shopping.flight_offers_search.get(@search_criteria.merge({max: 10})).data[0..10]
  end

  def new_search(amadeus_result, group, destination)

    @search = Search.create(@search_criteria)

    amadeus_result[..10].each_with_index do |result, offer_index|

      next if result["itineraries"].map{|i| i["segments"].count}.max > 2

      result["itineraries"].each_with_index do |itinerary, leg_index|
        itinerary["segments"].each do |segment|
          @flight = new_or_found_flight(segment, group, destination)

          search_result = SearchResult.create(
            search: @search,
            flight: @flight,
            offer_index: offer_index,
            return_flight: leg_index == 1,
            cost_per_head: result["price"]["total"].to_f/result["travelerPricings"].count
          )

        end
      end
    end
    @search
  end

  def new_or_found_flight(segment, group, destination)
      Flight.find_by(
        flight_code: "#{segment['carrierCode']} #{segment['number']}",
        departure_time: segment["departure"]["at"]
      ) || Flight.create(
        departure_time: segment["departure"]["at"],
        arrival_time: segment["arrival"]["at"],
        departure_airport_id: airport_id(segment["departure"], group["location"]),
        arrival_airport_id: airport_id(segment["arrival"], Location.find_by_city_code(destination)),
        flight_code: "#{segment['carrierCode']} #{segment['number']}"
      )
  end

  def airport_id(flight, location)
    a = Airport.find_by_code(flight["iataCode"]) || Airport.create(code: flight["iataCode"], location: location)
    a.id
  end
end
