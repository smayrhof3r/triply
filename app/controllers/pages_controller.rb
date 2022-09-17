class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  def home
    # Itinerary.delete_unclaimed
    @popular_images = []
    Search::DESTINATIONS.sample(3).each do |location|
      @popular_images << Location.find_by(city_code: location).images.first
    end
  end
end
