class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: :default_url_options
  before_action :configure_permitted_parameters, if: :devise_controller?

  # https://www.lewagon.com/blog/setup-meta-tags-rails
  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  def configure_permitted_parameters
    # For additional fields in app/views/devise/registrations/new.html.erb
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :home_city_id])

    # For additional in app/views/devise/registrations/edit.html.erb
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :home_city_id])

    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:first_name, :last_name, :home_city_id])
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || '/search'
  end

end
