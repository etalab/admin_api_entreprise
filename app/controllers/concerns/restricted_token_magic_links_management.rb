module RestrictedTokenMagicLinksManagement
  def new
    @token = Token.find(params[:id])

    render 'shared/restricted_token_magic_links/new'
  end

  def create
    @token = Token.find(params[:id])

    if access_allowed_for_current_user?
      if organizer.success?
        success_message(title: t('concerns.restricted_token_magic_links_management.create.success.title', target_email:))
      else
        error_message(title: t('concerns.restricted_token_magic_links_management.create.error.title', support_email: t("#{namespace}.support_email")))
      end

      redirect_to authorization_requests_path
    else
      head :forbidden
    end
  end

  private

  def organizer
    @organizer ||= Token::DeliverMagicLinkToEmail.call(
      email: target_email,
      token_id: @token.id,
      expires_at: 4.hours.from_now,
      host: request.host
    )
  end

  def target_email
    params[:email]
  end

  def access_allowed_for_current_user?
    @token.demandeurs.include?(current_user)
  end
end
