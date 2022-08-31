class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @user_itineraries = @user.itineraries
  end
end
