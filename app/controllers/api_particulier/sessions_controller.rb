class APIParticulier::SessionsController < APIParticulierController
  include SessionsManagement

  protected

  def oauth_login_organizer
    APIParticulier::User::OAuthLogin
  end
end
