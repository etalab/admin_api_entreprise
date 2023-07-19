module PublicTokenMagicLinksManagement
  extend ActiveSupport::Concern

  def show
    @magic_link = MagicLink.find_by(access_token: magic_token_show_params[:access_token])

    handle_invalid_magic_link!
  end

  private

  def handle_invalid_magic_link!
    if @magic_link.blank?
      handle_error!('unknown')
    elsif @magic_link.expired?
      handle_error!('expired', initial_expiration_delay_in_hours: @magic_link.initial_expiration_delay_in_hours)
    elsif @magic_link.tokens.blank?
      handle_error!('missing')
    end
  end

  def handle_error!(error_type, i18n_params = {})
    error_message(
      title: t("#{namespace}.public_token_magic_links.show.error.#{error_type}.title"),
      description: t("#{namespace}.public_token_magic_links.show.error.#{error_type}.description", **i18n_params)
    )
    redirect_to login_path
  end

  def magic_token_show_params
    {
      access_token: params.require(:access_token)
    }
  end
end
