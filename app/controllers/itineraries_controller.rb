class ItinerariesController < ApplicationController
  def search
  end

  def show
   @itinerary = Itinerary.find(params[id])
   @location = Location.find(@itinerary.destination)
   @status = Booking.confirmed
  end

  def index
    @p = params
  end
end
