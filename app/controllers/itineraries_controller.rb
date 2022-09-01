class ItinerariesController < ApplicationController
  before_action :update_session_url, only: [:search, :index, :show]
  skip_before_action :authenticate_user!

  AMADEUS = Amadeus::Client.new({
    client_id: ENV['AMADEUS_TEST_KEY'],
    client_secret: ENV['AMADEUS_TEST_API_SECRET']
  })

  def search
  end

  def show
   @itinerary = Itinerary.find(params["id"])
   @location = @itinerary.destination
   @permission = Permission.new
   session["user_return_to"] = request.original_url

  #  @status = Booking.confirmed?
  end

  def index
    if session[:params] == params
      @itineraries = session[:itineraries].map { |i| Itinerary.find(i) }

    else
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
    end

    if @itineraries.count(&:nil?) > 0
      update_session_variables
      session[:itineraries] = []
      redirect_to itineraries_path, alert: "reloaded due to missing itineraries"
    else
      @loc =  @itineraries.map do |itinerary|
        Location.find(itinerary.destination_id)
      end

      update_session_variables
      @images_by_itinerary_id = bulk_retrieve_location_images(session[:itineraries])
    end
  end

  def seed(params)
      count = 1

      # try each destination
      possible_destinations.each do |destination|
        puts destination

        groups = (1..count).to_a.map { |i|
          adults = params["adults#{i}"]
          children = params["children#{i}"]
          location = Location.find_by_city(params["origin_city#{i}"])
          {
            adults: adults,
            children: children,
            location: location,
            origin_city_id: location.id
          }
        }

        next if groups.map { |g| g[:location].city_code }.include?(destination)

        # find valid destinations and create itineraries
        groups.each do |group|
          # retrieve or find & save top flights
          @search_criteria = {
            originLocationCode: group[:location].city_code,
            destinationLocationCode: destination,
            departureDate: params["start_date"],
            returnDate: params["end_date"],
            adults: group[:adults],
            children: group[:children]
          }

          group[:search] = Search.find_by(@search_criteria) || new_search(
            amadeus_search_result, group, destination)

          puts "#{@search_criteria} : #{group[:search]}"
        end
      end
  end

  private

  def update_session_url
    session[:previous_request_url] = session[:current_request_url]
    session[:current_request_url] = request.original_url
  end

  def update_session_variables
    # should be able to destroy underlying models by destroying itineraries, but not working so we nest in
    Itinerary.delete_unclaimed(session[:itineraries]) if session[:itineraries]

    session[:itineraries] = @itineraries.map(&:id)
    session[:params] = params
  end

  def create_itinerary_and_bookings_for(groups, destination)
    # for each destination we only create ONE itinerary and set of passenger groups but MANY bookings
    itinerary = Itinerary.create(destination_id: destination.id, start_date: params["start_date"], end_date: params["end_date"])
    groups.each do |group|
      passenger_group = new_passenger_group(group, itinerary)
      cheapest_offer = group[:search].search_results.first

      Booking.create(
        passenger_group: passenger_group,
        search_result_id: cheapest_offer.id,
        status: "suggested"
      )
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
    AMADEUS.shopping.flight_offers_search.get(@search_criteria.merge({max: 10})).data[0..10]
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

  def bulk_retrieve_location_images(ids=[])
    unless ids.empty?
      sql = "
      SELECT itineraries.id as id, images.url as url
      FROM images
      INNER JOIN locations ON images.location_id = locations.id
      INNER JOIN itineraries ON itineraries.destination_id = locations.id
      WHERE itineraries.id in (#{ids.join(',')})"
      @result = ActiveRecord::Base.connection.execute(sql)
      @result_mapped=@result.map do |r|
        [r["id"], r["url"]]
      end.to_h
      return @result_mapped
    end
    {}
  end
end
