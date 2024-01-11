module TransferTokensManagement
  def new
    @token = Token.find(params[:id])

    render 'shared/transfer_tokens/new'
  end

  def create
    @token = Token.find(params[:id])

    if access_allowed_for_current_user?
      if organizer.success?
        success_message(title: t('shared.transfer_tokens.create.success.title', target_email:))
      else
        error_message(title: t('shared.transfer_tokens.create.error.title', support_email: t("#{namespace}.support_email")))
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
