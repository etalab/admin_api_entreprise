class APIEntreprise::SessionsController < APIEntrepriseController
  include SessionsManagement

  protected

  def login_organizer
    APIEntreprise::User::Login
  end
end
