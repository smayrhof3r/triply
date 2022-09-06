class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  def home
    Itinerary.delete_unclaimed
    @locations = Search::DESTINATIONS.sample(3)
    end
  end
