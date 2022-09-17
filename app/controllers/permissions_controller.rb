class PermissionsController < ApplicationController

  def create
    p = Permission.new(permission_params)
    session[:invited_user] = nil 

    if p.save && p.role == "owner"
      Itinerary.delete_unclaimed(session[:itineraries])
      redirect_to itinerary_path(params["itinerary_id"]), notice: "Itinerary saved! Add flights below."
    elsif p.save && p.role == "guest"
      redirect_to user_path(current_user), notice: "User #{p.user.email} now has access"
    else
      redirect_to itinerary_path(params["itinerary_id"]), notice: "Failed to save or share itinerary! Are you logged in?"
    end
  end

  protected

  def permission_params
    params.require(:permission).permit(:role, :user_id, :itinerary_id)
  end
end
