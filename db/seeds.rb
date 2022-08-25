
Image.delete_all
Airport.delete_all
Location.delete_all


f = File.open('airports.json')
locations = JSON.parse(f.read)

# "ORBAirportList": [
#   {
#     "airportCode": "YUL",
#     "airportName": "Pierre Elliott Trudeau Intl",
#     "cityCode": "YMQ",
#     "cityName": "Montreal",
#     "countryCode": "CA",
#     "countryName": "Canada",
#     "isORBOrigin": "true",
#     "isORBDestination": "true",
#     "excludedCountries": ""
#   },


locations["ORBAirportList"].each do |location|
  # create location
  l = Location.find_by_city(location["cityName"])

  unless l
    l = Location.create(
      city: location["cityName"],
      city_code: location["cityCode"],
      country: location["countryName"],
      country_code: location["countryCode"]
    )

    # get some images
    sleep(0.5)
    photos = Unsplash::Photo.search(l.city)
                            .first(5)
                            .map { |result| result.urls["raw"] }
    photos.each do |photo|
      Image.create(url: photo, location: l)
    end

    # get coordinates
    res = Faraday.get("https://api.mapbox.com/geocoding/v5/mapbox.places/#{l.city.gsub(' ', '%20')}.json?country=#{l.country_code}&limit=1&types=place&access_token=#{ENV['MAPBOX_KEY']}")
    json = JSON.parse(res.body)
    if !json["features"].empty?
      gps = json["features"].first["geometry"]["coordinates"]
      l.longitude = gps[0]
      l.latitude = gps[1]
      l.save
    end
  end

  # create the Airport
  a = Airport.create(
    name: location["airportName"],
    code: location["airportCode"],
    location: l
  )
end