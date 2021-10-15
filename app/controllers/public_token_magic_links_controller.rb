class PublicTokenMagicLinksController < ApplicationController
  def show
    retrieve_jwt = JwtAPIEntreprise::Operation::RetrieveFromMagicLink.call(params: params)

    if retrieve_jwt.success?
      @token = retrieve_jwt[:jwt]
    else
      error_message(title: t('.error.title'))
      redirect_to login_path
    end
  end
end
