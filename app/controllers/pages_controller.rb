class PagesController < ApplicationController
  def home
    Itinerary.delete_unclaimed
  end
end
