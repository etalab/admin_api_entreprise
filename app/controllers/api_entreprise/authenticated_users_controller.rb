class APIEntreprise::AuthenticatedUsersController < APIEntrepriseController
  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :logged_user_not_authorized

  layout 'api_entreprise/authenticated_user'

  private

  def authenticate_user!
    return if user_signed_in?

    error_message(title: t('api_entreprise.sessions.unauthorized.signed_out.error.title'))

    redirect_to login_path
  end

  def logged_user_not_authorized
    error_message(title: t('api_entreprise.sessions.unauthorized.signed_in.error.title'))

    redirect_to user_profile_path
  end
end
