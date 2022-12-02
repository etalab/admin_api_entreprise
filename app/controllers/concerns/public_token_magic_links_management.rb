module PublicTokenMagicLinksManagement
  extend ActiveSupport::Concern

  def show
    @magic_link = MagicLink.find_by(access_token:)

    handle_invalid_magic_link!
  end

  def create
    MagicLink::CreateAndSend.call(email:, host: request.host) unless valid_magic_link_already_exist?

    success_message(
      title: t("#{namespace}.public_token_magic_links.create.title"),
      description: t("#{namespace}.public_token_magic_links.create.description")
    )
    redirect_to login_path
  end

  def new; end

  private

  def valid_magic_link_already_exist?
    MagicLink.unexpired.find_by(email:).present?
  end

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

  def access_token
    params.require(:access_token)
  end

  def email
    params.require(:email)
  end
end
