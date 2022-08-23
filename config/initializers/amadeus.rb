require 'amadeus'

amadeus = Amadeus::Client.new({
    client_id: ENV['AMADEUS_TEST_KEY'],
    client_secret: ENV['AMADEUS_TEST_API_SECRET']
})

# begin
#     departure_code = 'NYC'
#     arrival_code = 'MAD'
#     departure_date = '2021-05-01'
#     number_adults = 1
#     puts amadeus.shopping.flight_offers_search.get(originLocationCode: "#{departure_code}", destinationLocationCode: "#{arrival_code}", departureDate: "#{departure_date}", adults: "#{number_adults}", max: 1).body
# rescue Amadeus::ResponseError => error
#     puts error
# end
