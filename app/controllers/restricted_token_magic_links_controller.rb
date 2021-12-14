class RestrictedTokenMagicLinksController < AuthenticatedUsersController
  def create
    @token = JwtAPIEntreprise.find(params[:id])

    if access_allowed_for_current_user?
      send_magic_link = Token::CreateMagicLink.call(
        token: @token,
        email: target_email,
      )

      if send_magic_link.success?
        success_message(title: t('.success.title', target_email: target_email))
      else
        error_message(title: t('.error.title'))
      end

      redirect_back fallback_location: root_path
    else
      head :forbidden
    end
  end

  private

  def target_email
    params[:email]
  end

  def access_allowed_for_current_user?
    current_user == @token.user ||
      current_user.admin?
  end
end
