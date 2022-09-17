class ItinerariesController < ApplicationController
  before_action :update_session_url, only: [:search, :index, :show]
  before_action :retrieve_itinerary, only: [:destroy, :show]

  skip_before_action :authenticate_user!

  AMADEUS = Amadeus::Client.new({
    client_id: ENV['AMADEUS_TEST_KEY'],
    client_secret: ENV['AMADEUS_TEST_API_SECRET']
  })

  @@airport_info = {}

  def search
  end

  def destroy

    if Permission.find_by(user: current_user, itinerary: @itinerary).role == "owner"

      @itinerary.permissions.each(&:delete)

      @itinerary.passenger_groups.each do |p|
        p.bookings.each(&:delete)
        p.delete
      end

      @itinerary.delete
    end

    redirect_to user_path(current_user)
  end

  def show
    @location = @itinerary.destination
    @permission = Permission.new
    @permission.itinerary = @itinerary
    @permission.user = current_user
    @permission.role = "owner"
    session["user_return_to"] = request.original_url

    session[:itinerary_shown] = @itinerary.id

    respond_to do |format|
      format.html { render 'itineraries/show'}
      format.text { render partial: "users/small_flight_info_card", locals: { itinerary: @itinerary, permission: @permission }, formats: [:html] }

    end
  end

  def search_index
    # check if search is needed
    if session[:params] == params && !session[:itineraries].empty?
      @itineraries = session[:itineraries].map { |i| Itinerary.find_by(id: i) }
      if @itineraries.count(&:nil?) > 0
        Itinerary.delete_unclaimed(session[:itineraries]) if session[:itineraries]
        session[:itineraries] = []
        session[:params] = {}
      else
        return respond_to do |format|
          format.text
        end
      end

    else
      @user_itineraries = user_signed_in? ? current_user.relevant_itineraries(params) : {}

      possible_destinations.each do |destination|
        retrieve_search_results(destination) unless @user_itineraries[destination]
      end

      return respond_to do |format|
        format.text
      end
    end
  end

  def index
    remove_empty_passenger_groups
    remove_empty_return_date

    if session[:params] == params && !session[:itineraries].empty?
      @itineraries = session[:itineraries].map { |i| Itinerary.find_by(id: i) }
    else
      @itineraries = []
      @user_itineraries = user_signed_in? ? current_user.relevant_itineraries(params) : {}

      # try each destination
      possible_destinations.each do |destination|
        @itineraries << (@user_itineraries[destination] || new_itinerary(destination))
        source_images(destination) if (!@itineraries.last == "" && @itineraries.last.destination.images.empty?)
      end
    end

    if @itineraries.count(&:nil?) > 0
      Itinerary.delete_unclaimed(session[:itineraries]) if session[:itineraries]
      session[:itineraries] = []
      session[:params] = {}
      redirect_to '/search', alert: "restart search or view your itineraries from the menu provided"
    else
      @itineraries = @itineraries.filter { |i| i != "" }
      sort_itineraries
      filter_direct_flights
      apply_budget_filter

      update_session_variables
      @images_by_itinerary_id = Image.retrieve_all_by_itinerary(@itineraries)
    end
  end

  def filter_direct_flights
    if params["direct_flights"]
      @itineraries.filter!(&:direct_flight)
    end
  end

  def sort_itineraries
    case params[:sort]
    when "Price Descending"
      @itineraries = @itineraries.sort_by(&:total_cost).reverse
    when "Price Ascending"
      @itineraries = @itineraries.sort_by(&:total_cost)
    when "Shortest flights"
      @itineraries = @itineraries.sort_by(&:total_time)
    end
  end

  def seed(params)
      count = 1

      # try each destination
      Search::DESTINATIONS.each do |destination|

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

  def retrieve_itinerary
    @itinerary = Itinerary.find(params[:id])
  end

  def source_images(destination)
    l = Location.find_by(city_code: destination)
    photos = Unsplash::Photo.search(l.city)
                          .first(5)
                          .map { |result| result.urls["regular"] }
    photos.each do |photo|
      Image.create(url: photo, location: l)
    end
  end

  def apply_budget_filter
    unless params["range_primary"].to_i == 0
      budget = params["range_primary"].to_i
      @itineraries.filter! { |i| i.total_cost <= budget }
    end
  end

  def remove_empty_passenger_groups
    count = params["passenger_group_count"].to_i
    (1..count).to_a.each do |i|
      next unless invalid_group(i)
      params.delete("origin_city#{i}")
      params.delete("adults#{i}")
      params.delete("children#{i}")
      params["passenger_group_count"] = (count - 1).to_s
      count -= 1
    end
  end

  def remove_empty_return_date
    params.delete("end_date") if params["end_date"] == ""
  end

  def invalid_group(i)
    invalid_city = (params["origin_city#{i}"] == "")
    invalid_people = (params["adults#{i}"] == "" && params["children#{i}"] == "")
    invalid_city || invalid_people
  end

  def new_itinerary(destination)
    valid_destination = true

    retrieve_search_results(destination)

    if !group[:search].amadeus_response.empty?
      create_itinerary_and_bookings_for(groups, Location.find_by_city_code(destination))
    else
      return ""
    end
  end

  def retrieve_search_results(destination)
    count = params["passenger_group_count"].to_i
    groups = (1..count).to_a.map { |i| passenger_group_params(i) }

    return "" if groups.map { |g| g[:location].city_code }.include?(destination)

    # find valid destinations and create itineraries
    groups.each do |group|
      # retrieve or find & save top flights
      group[:search] = top_search_results(group, destination)

      # skip to next destination if not all groups can fly there
      if group[:search].amadeus_response.empty?
        break
      end
    end
  end

  def update_session_url
    session[:previous_request_url] = session[:current_request_url]
    session[:current_request_url] = request.original_url
  end

  def update_session_variables
    # should be able to destroy underlying models by destroying itineraries, but not working so we nest in
    if session[:itineraries] && (session[:itineraries] != @itineraries.map{|i| i.id})
      Itinerary.delete_unclaimed(session[:itineraries]) unless session[:itineraries].empty?
    end
    session[:itineraries] = @itineraries.filter{|i| !i.nil?}.map(&:id)
    session[:params] = params
  end

  def create_itinerary_and_bookings_for(groups, destination)
    # for each destination we only create ONE itinerary and set of passenger groups but MANY bookings
    itinerary = Itinerary.create(destination_id: destination.id, start_date: params["start_date"], end_date: params["end_date"])
    groups.each do |group|
      passenger_group = new_passenger_group(group, itinerary)
      search_results = group[:search].amadeus_response["offers"]

      cheapest_offer = search_results.first

      Booking.create(
        passenger_group: passenger_group,
        status: "cheapest",
        offer: cheapest_offer
      )

      shortest_flight = search_results.sort_by { |offer| flight_time(offer) }.first
      Booking.create(
        passenger_group: passenger_group,
        status: "shortest",
        offer: shortest_flight
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
    return Search::DESTINATIONS if (params["destination"].nil? || params["destination"].empty?)

    [params["destination"]]
  end

  def passenger_group_params(i)
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
    AMADEUS.shopping.flight_offers_search.get(@search_criteria.merge({max: 10})).data[0..10]
  end

  def new_search(amadeus_result, group, destination)

    @search = Search.create(@search_criteria)
    destination_location = Location.find_by_city_code(destination)
    @search.amadeus_response = {}
    @search.amadeus_response[:offers] = []

    amadeus_result[..10].each_with_index do |result, offer_index|
      next if result["itineraries"].map{|i| i["segments"].count}.max > 3
      new_result = {}

      new_result[:flights_there] = get_flights_array(result["itineraries"].first["segments"], group[:location], destination_location)
      if result["itineraries"].count > 1
        new_result[:flights_return] = get_flights_array(result["itineraries"].last["segments"], destination_location, group[:location])
      end
      new_result[:cost_per_head] = result["price"]["total"].to_f/result["travelerPricings"].count
      @search.amadeus_response[:offers] << new_result unless new_result.empty?
    end
    @search.save
    @search
  end

  def get_flights_array(segments, from, to)
    s = segments.map do |segment|
      airline = find_or_create_airline(segment['carrierCode'])
      airline = airline ? airline.name : ""

      airport_from = find_or_create_airport(segment["departure"]["iataCode"])
      airport_to = find_or_create_airport(segment["arrival"]["iataCode"])
      {
        departure_time: segment["departure"]["at"],
        arrival_time: segment["arrival"]["at"],
        departure_city: airport_from ? airport_from.location.city : airport_from.name,
        arrival_city: airport_to ? airport_to.location.city : airport_to.name,
        flight_code: "#{segment['carrierCode']} #{segment['number']}",
        airline: airline,
        duration: ActiveSupport::Duration.parse(segment["duration"])
      }
    end
    return s
  end

  def airport_id(flight, location)
    a = Airport.find_by_code(flight["iataCode"]) || Airport.create(code: flight["iataCode"], location: location)
    a.id
  end

  def flight_time(offer)
    total = offer["flights_there"].map { |f| f["duration"] }.sum
    total += offer["flights_return"].map { |f| f["duration"] }.sum if offer["flights_return"]
    total
  end

  def find_or_create_airline(iata)
    airline = Airline.find_by(iata_code: iata)
    return airline unless airline.nil?

    data = Faraday.get('https://raw.githubusercontent.com/jpatokal/openflights/master/data/airlines.dat')
    airline_info = data.body.gsub("\"", "").split("\n").map { |l| l.split(",") }.filter { |a| a[3] == iata }.flatten

    return nil if airline_info.empty?

    a = Airline.create(
      iata_code: iata,
      name: airline_info[1]
    )

    return a
  end

  def find_or_create_airport(iata)
    airport = Airport.find_by(code: iata)
    return airport unless airport.nil?

    data = Faraday.get("https://raw.githubusercontent.com/mwgg/Airports/master/airports.json") if @@airport_info.empty?
    @@airport_info = JSON.parse(data.body) if @@airport_info.empty?
    airport_data = @@airport_info.find { |k, v| v["iata"] == iata }
    if airport_data.nil?
      location = Location.find_by(city:"UNKNOWN") || Location.create(city:"UNKNOWN")
      airport = Airport.create(name: iata, code: iata, location: location)
    else
      location = Location.find_by(city: airport_data.last["city"]) || Location.create(
        city: airport_data.last["city"],
        country: airport_data.last["country"],
        latitude: airport_data.last["lat"],
        longitude: airport_data.last["lon"]
      )
      airport = Airport.create(name: airport_data.last["name"], code: iata, location: location)
    end
    airport
  end

end
