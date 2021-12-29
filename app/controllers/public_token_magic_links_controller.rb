class PublicTokenMagicLinksController < ApplicationController
  def show
    retrieve_jwt = Token::RetrieveFromMagicLink.call(magic_token: params[:token])

    if retrieve_jwt.success?
      @token = retrieve_jwt.jwt
    else
      error_message(title: t('.error.title'), description: t('.error.description'))
      redirect_to login_path
    end
  end
end
