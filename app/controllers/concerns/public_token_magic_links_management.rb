module PublicTokenMagicLinksManagement
  extend ActiveSupport::Concern

  def show
    @magic_link = MagicLink.find_by(access_token:)

    handle_invalid_magic_link!
  end

  def create
    if user.present?
      create_and_send_magic_link_user
    elsif contact.present?
      create_and_send_magic_link_contact
    end

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

  def create_and_send_magic_link_user
    create_magic_link

    UserMailer.magic_link_signin(@magic_link, request.host).deliver_later
  end

  def create_and_send_magic_link_contact
    create_magic_link

    TokenMailer.magic_link(@magic_link, request.host).deliver_later
  end

  def create_magic_link
    @magic_link = MagicLink.create!(email:)
  end

  def contact
    Contact.find_by(email:)
  end

  def user
    User.find_by(email:)
  end

  def access_token
    params.require(:access_token)
  end

  def email
    params.require(:email)
  end
end
