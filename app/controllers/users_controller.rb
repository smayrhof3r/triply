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

    unless @shown_itinerary && Itinerary.find_by(id: @shown_itinerary) && current_user.permissions.find_by(itinerary_id: @shown_itinerary)
      @shown_itinerary = @upcoming_itineraries.first.id unless @upcoming_itineraries.empty?
      @shown_itinerary ||= @past_itineraries.first.id unless @past_itineraries.empty?

    end
    @permission = Permission.new
    @permission.itinerary_id = session[:itinerary_shown] || @upcoming_itineraries.first.id
    @permission.role = "guest"
    @permission.user = User.find_by(email: session[:invited_user]) if session[:invited_user]
    session[:current_request_url] = request.original_url
  end
end
