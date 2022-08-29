class APIParticulier::PagesController < APIParticulierController
  def home
    redirect_to api_particulier_login_path
  end
end
