class PassengerGroup < ApplicationRecord
  belongs_to :itinerary
  has_many :bookings #, dependent: :destroy

  def origin_city
    Location.find(origin_city_id)
  end

  def flight_info
    suggested_bookings = bookings.filter do |booking|
      booking.status = "suggested" || booking.status = "confirmed"
    end
    info = {flight_there: [], flight_return: []}
    suggested_bookings.each do |booking|
      s = booking.search_result
      f = s.flight
      if s.return_flight
        info[:flight_return] << f
      else
        info[:flight_there] << f
      end
    end
    info[:flight_return].sort! {|f| f.departure_time}
    info[:flight_there].sort! {|f| f.departure_time}
    info
  end

  def to_param_hash
    {
      origin: Location.find(origin_city_id).city,
      adults: adults,
      children: children,
    }
  end

end
