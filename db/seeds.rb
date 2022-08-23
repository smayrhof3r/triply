locations = [
  ['Paris', 'France', 'Europe'],
  ['New York', 'USA', 'North America'],
  ['London', 'England', 'Europe'],
  ['Bangkok', 'Thailand', 'Asia'],
  ['Hong Kong', 'China', 'Asia'],
  ['Dubai', 'UAE', 'Middle East'],
  ['Singapore', 'Singapore', 'Asia'],
  ['Rome', 'Italy', 'Europe'],
  ['Macau', 'Portugal', 'Europe'],
  ['Istanbul', 'Turkey', 'Europe'],
  ['Kuala Lumpur', 'Malaysia', 'Asia'],
  ['Delhi', 'India', 'Asia'],
  ['Tokyo', 'Japan', 'Asia'],
  ['Antalya', 'Turkey', 'Asia'],
  ['Mexico City', 'Mexico', 'North America'],
  ['Moscow', 'Russia', 'Asia'],
  ['Porto', 'Portugal', 'Europe'],
  ['San Francisco', 'USA', 'North America'],
  ['Beijing', 'China', 'Asia'],
  ['Los Angelos', 'USA', 'North America'],
  ['Chicago', 'USA', 'North America'],
  ['Barcelona', 'Spain', 'Europe'],
  ['Abu Dhabi', 'UAE', 'Middle East'],
  ['Amsterdam', 'Netherlands', 'Europe'],
  ['Madrid', 'Spain', 'Europe'],
  ['Sydney', 'Australia', 'Asia'],
  ['San Miguel de Allende', 'Mexico', 'North America'],
  ['Lisbon', 'Portugal', 'Europe'],
  ['Vienna', 'Austria', 'Germany'],
  ['Johannesburg', 'South Africa', 'Africa']
]

# locations.each do |location|
#   l = Location.create(city: location[0], country: location[1], region: location[2])
#   photos = Unsplash::Photo.search(location[0])
#                           .first(5)
#                           .map { |result| result.urls["raw"] }
#   photos.each do |photo|
#     i = Image.create(url: photo, location: l)
#   end
#   puts l
# end

Location.all.each do |l|
  res = Faraday.get("https://api.mapbox.com/geocoding/v5/mapbox.places/#{l.city.gsub(' ', '%20')},#{l.country.gsub(' ', '%20')}.json?types=address&fuzzyMatch=true&autocomplete=true&limit=1&access_token=#{ENV['MAPBOX_KEY']}")
  json = JSON.parse(res.body)
  if !json["features"].empty?
    gps = json["features"].first["geometry"]["coordinates"]
    l.longitude = gps[0]
    l.latitude = gps[1]
    l.save
  end
end

amadeus = Amadeus::Client.new({
  client_id: ENV['AMADEUS_TEST_KEY'],
  client_secret: ENV['AMADEUS_TEST_API_SECRET']
})

Location.all.each do |location|
  if location.airports.empty? && location.longitude && location.latitude
    sleep(2)
    airports = amadeus.reference_data.locations.airports.get(longitude: location.longitude, latitude: location.latitude)
    local_airports = airports.data.filter do |airport|
      airport["address"]["cityName"] == location.city.upcase
    end

    local_airports = [airports.data.first] if local_airports.empty?

    local_airports.each do |airport|
      if airport && airport["name"] && airport["iataCode"]
        a = Airport.new(name: airport["name"], code: airport["iataCode"])
        a.location = location
        a.save
      end
    end
  end

  if location.airports.empty?
    location.images.each {|i| i.delete}
    location.delete
  end
end
