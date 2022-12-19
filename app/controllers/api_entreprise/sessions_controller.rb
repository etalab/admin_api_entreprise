class APIEntreprise::SessionsController < APIEntrepriseController
  include SessionsManagement

  protected

  def oauth_login_organizer
    APIEntreprise::User::OAuthLogin
  end
end
