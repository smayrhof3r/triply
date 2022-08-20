# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
Rails.application.load_server

Unsplash.configure do |config|
  config.application_access_key = ENV['UNSPLASH_KEY']
  config.application_secret = ENV['UNSPLASH_SECRET']
  #config.application_redirect_uri = "https://www.triply.world/oauth/callback"
  config.utm_source = "triply"
end
