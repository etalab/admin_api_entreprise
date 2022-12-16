class APIParticulier::SessionsController < APIParticulierController
  include SessionsManagement

  protected

  def login_organizer
    APIParticulier::User::Login
  end
end
