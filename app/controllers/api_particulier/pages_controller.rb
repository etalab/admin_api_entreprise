class APIParticulier::PagesController < APIParticulierController
  def home
    @providers = APIParticulier::Provider.all
  end

  def redoc
    render 'shared/pages/redoc'
  end
end
