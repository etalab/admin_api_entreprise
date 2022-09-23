module PublicTokenMagicLinksManagement
  extend ActiveSupport::Concern

  def show
    retrieve_token = Token::RetrieveFromMagicLink.call(magic_token: params[:token], expiration_offset:)

    if retrieve_token.success?
      @token = retrieve_token.token
    else
      error_message(title: t("#{namespace}.public_token_magic_links.show.error.title"), description: t("#{namespace}.public_token_magic_links.show.error.description"))
      redirect_to login_path
    end
  end

  protected

  def expiration_offset
    nil
  end
end
