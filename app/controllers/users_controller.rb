class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @user_itineraries = @user.itineraries

    @upcoming_itineraries = @user_itineraries.map {|i| i.start_date >= Date.today ? i : nil}.reject(&:nil?) 
    @past_itineraries = @user_itineraries.map {|i| i.start_date < Date.today ? i : nil}.reject(&:nil?)

  end
end
