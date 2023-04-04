class APIParticulier::DocumentationController < APIParticulierController
  layout 'api_particulier/no_container'

  def developers
    @documentation_page = APIParticulier::DocumentationPage.find('developers')

    render 'index'
  end
end
