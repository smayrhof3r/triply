class UsersController < ApplicationController
  before_action :authenticate_user!
  def show

    if !current_user || (current_user.id != params[:id].to_i)
      redirect_to root_path
    end

    @invited_user = session[:invited_user]
    @shown_itinerary = session[:itinerary_shown]
    @user = User.find(params[:id])
    @user_itineraries = @user.itineraries
    @upcoming_itineraries = @user_itineraries.map {|i| i.start_date >= Date.today ? i : nil}.reject(&:nil?)
    @past_itineraries = @user_itineraries.map {|i| i.start_date < Date.today ? i : nil}.reject(&:nil?)
    @permission = Permission.new
    @permission.itinerary_id = session[:itinerary_shown] || @upcoming_itineraries.first.id
    @permission.role = "guest"
    @permission.user = User.find_by(email: session[:invited_user]) if session[:invited_user]
    session[:current_request_url] = request.original_url
  end
end
