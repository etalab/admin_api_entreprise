module PublicTokenMagicLinksManagement
  extend ActiveSupport::Concern

  def show
    @magic_link = MagicLink.find_by(access_token:)

    handle_invalid_magic_link!
  end

  def create
    create_and_send_magic_link if Contact.find_by(email:) || User.find_by(email:)

    success_message(
      title: t("#{namespace}.public_token_magic_links.create.title"),
      description: t("#{namespace}.public_token_magic_links.create.description")
    )
    redirect_to login_path
  end

  def new; end

  protected

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

  def create_and_send_magic_link
    @magic_link = MagicLink.create!(email:)

    TokenMailer.magic_link(@magic_link, request.host).deliver_later
  end

  def access_token
    params.require(:token)
  end

  def email
    params.require(:email)
  end
end
