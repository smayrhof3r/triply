class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  def home
    Itinerary.delete_unclaimed
    @locations = Search::DESTINATIONS.sample(3)
    # from code i need to make it city
    # images.location_id = locations.id
    # for each city i need photo
    # image.url
    # @image_popular = @location.image
    end
  end
