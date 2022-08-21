class ApplicationController < ActionController::Base

  # https://www.lewagon.com/blog/setup-meta-tags-rails
  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end
end
