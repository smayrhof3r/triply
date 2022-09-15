class BookingsController < ApplicationController
  def update 
    @booking = Booking.find(params["id"])
    @booking.update(booking_params)

    respond_to |format|
      format.html { redirect_to itinerary[:id]}
      format.text { render partial: "bookings_by_group", locals: { group: group }, formats: [:html] }  
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:passenger_group_id, :status, :offer)
  end
end
