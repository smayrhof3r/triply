class PermissionsController < ApplicationController

  def create
    p = Permission.new(
      user: current_user,
      itinerary_id: params["itinerary_id"],
      role: 'owner'
    )


    if p.save
      Itinerary.delete_unclaimed(session[:itineraries])
      redirect_to itinerary_path(params["itinerary_id"]), notice: "Itinerary saved! Add flights below."
    else
      redirect_to itinerary_path(params["itinerary_id"]), notice: "Failed to save itinerary! Are you logged in?"
    end
  end
end
