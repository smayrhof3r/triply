class Users::InvitationsController < Devise::InvitationsController
  skip_before_action :authenticate_user!

  def new
    session[:previous_request_url] = session[:current_request_url]
    session[:current_request_url] = request.original_url

    super
  end

  def after_invite_path_for(resource)
    session[:previous_request_url]
  end

  def invite_resource
    session[:invited_user] = params[:user][:email]
    super
  end
end
