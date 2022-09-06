class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  def home
    Itinerary.delete_unclaimed
    session[:itineraries] = []
    session[:params] = []
  end
end
