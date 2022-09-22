class BookingsController < ApplicationController
  def update

    @booking = Booking.find(params["id"])
    puts "BOOKING..........#{@booking}"
    @booking.update(booking_params)
    puts "UPDATED BOOKING..........#{@booking}"
    @booking.save
    puts "SAVED BOOKING..........#{@booking}"

    if @booking.status == "confirmed"
      @booking.passenger_group.bookings.each do |b|
        if b.status != "confirmed"
          b.delete
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to itinerary_path(@booking.passenger_group.itinerary)}
      format.text { render partial: "itineraries/bookings_by_group", locals: { group: @booking.passenger_group }, formats: [:html] }
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:passenger_group_id, :status, :offer)
  end
end
