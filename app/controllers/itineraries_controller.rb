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
    end

    @loc =  @itineraries.map do |itinerary|
      Location.find(itinerary.destination_id)
    end

    update_session_variables
    @images_by_itinerary_id = bulk_retrieve_location_images(session[:itineraries])

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
    delete_itineraries if session[:itineraries]

    session[:itineraries] = @itineraries.map(&:id)
    session[:params] = params
  end

  def delete_itineraries
    # retrieve all relevant passenger group ids and booking ids based on itinerary_id in (..)
    unless session[:itineraries].nil? || session[:itineraries].empty?
      ids = retrieve_bookings_passengergrps_from_itinerary_ids_sql(session[:itineraries])
      unless ids.ntuples == 0
        b_ids = ids.map{|i| i["b_id"]}
        p_ids = ids.map{|i| i["p_id"]}.uniq

        delete_sql('bookings', b_ids) unless b_ids.empty?
        delete_sql('passenger_groups', p_ids) unless p_ids.empty?
      end

      delete_sql('itineraries', session[:itineraries])
    end
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


  def delete_sql(table, ids)
    sql = "DELETE FROM #{table} WHERE id in (#{ids.join(',')})"
    ActiveRecord::Base.connection.execute(sql)
  end

  def retrieve_bookings_passengergrps_from_itinerary_ids_sql(ids)
    sql = "
    SELECT passenger_groups.id as p_id, bookings.id as b_id
    FROM bookings
    INNER JOIN passenger_groups ON bookings.passenger_group_id = passenger_groups.id
    INNER JOIN itineraries ON passenger_groups.itinerary_id = itineraries.id
    WHERE itineraries.id in (#{ids.join(',')})"
    ActiveRecord::Base.connection.execute(sql)
  end

  def bulk_retrieve_location_images(ids)
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
    @result_mapped
  end
end
