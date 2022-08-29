class APIParticulier::SessionsController < APIParticulierController
  include SessionsManagement

  def login_organizer
    APIParticulier::User::Login
  end
end
