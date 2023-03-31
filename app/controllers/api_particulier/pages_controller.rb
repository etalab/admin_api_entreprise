class APIParticulier::PagesController < APIParticulierController
  def home
    @providers = APIParticulier::Provider.all
  end
end
