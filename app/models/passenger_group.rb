class PassengerGroup < ApplicationRecord
  belongs_to :itinerary
  has_many :bookings #, dependent: :destroy

  def origin_city
    Location.find(origin_city_id)
  end

  # def flight_info
  #   suggested_bookings = bookings.filter { |b| b.status == "confirmed" }
  #   suggested_bookings = bookings.filter { |b| b.status == "suggested" } if suggested_bookings.empty?

  #   info = {flight_there: [], flight_return: []}
  #   suggested_bookings.each do |booking|
  #     s = booking.search_result
  #     f = s.flight
  #     if s.return_flight
  #       info[:flight_return] << f
  #     else
  #       info[:flight_there] << f
  #     end
  #     info[:booking] = booking
  #   end

  #   info[:flight_return] = info[:flight_return].sort { |f| f.departure_time }.reverse
  #   info[:flight_there] = info[:flight_there].sort { |f| f.departure_time }.reverse

  #   info
  # end

  def departure_time
    b = bookings.filter{|b| b.status == "confirmed"}
    if b.empty?
      DateTime.new(1900, 1,1) # sort to beginning
    else
      b.first.offer["flights_there"].first["departure_time"]
    end
  end

  def total_cost

  end

  def to_param_hash
    {
      origin: Location.find(origin_city_id).city,
      adults: adults,
      children: children,
    }
  end

  def self.order_by_flight_info(groups)
    return groups.to_a.sort_by(&:departure_time)
  end

end
