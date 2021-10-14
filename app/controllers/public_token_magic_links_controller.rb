class PublicTokenMagicLinksController < ApplicationController
  def show
    retrieve_jwt = JwtAPIEntreprise::Operation::RetrieveFromMagicLink.call(params: params)

    if retrieve_jwt.success?
      @tokens = [retrieve_jwt[:jwt]]
      render 'jwt_api_entreprise/index'
    else
      error_message(title: t('.error.title'))
      redirect_to login_path
    end
  end
end
