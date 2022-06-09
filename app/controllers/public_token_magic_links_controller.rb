class PublicTokenMagicLinksController < ApplicationController
  def show
    retrieve_token = Token::RetrieveFromMagicLink.call(magic_token: params[:token])

    if retrieve_token.success?
      @token = retrieve_token.token
    else
      error_message(title: t('.error.title'), description: t('.error.description'))
      redirect_to login_path
    end
  end
end
