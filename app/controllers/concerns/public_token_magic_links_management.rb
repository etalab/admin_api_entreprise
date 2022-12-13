module PublicTokenMagicLinksManagement
  extend ActiveSupport::Concern

  def show
    @magic_link = MagicLink.find_by(access_token: magic_token_show_params[:access_token])

    handle_invalid_magic_link!
  end

  def create
    MagicLink::CreateAndSend.call(magic_token_create_params)

    success_message(
      title: t("#{namespace}.public_token_magic_links.create.title"),
      description: t("#{namespace}.public_token_magic_links.create.description")
    )

    redirect_to login_path
  end

  def new; end

  private

  def handle_invalid_magic_link!
    if @magic_link.blank?
      handle_error!('unknown')
    elsif @magic_link.expired?
      handle_error!('expired')
    elsif @magic_link.tokens.blank?
      handle_error!('missing')
    end
  end

  def handle_error!(error_type)
    error_message(
      title: t("#{namespace}.public_token_magic_links.show.error.#{error_type}.title"),
      description: t("#{namespace}.public_token_magic_links.show.error.#{error_type}.description")
    )
    redirect_to login_path
  end

  def magic_token_show_params
    {
      access_token: params.require(:access_token)
    }
  end

  def magic_token_create_params
    {
      email: params.require(:email),
      host: request.host
    }
  end
end
