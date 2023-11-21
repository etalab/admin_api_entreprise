module AuthenticatedUserManagement
  extend ActiveSupport::Concern

  included do
    rescue_from Pundit::NotAuthorizedError, with: :logged_user_not_authorized

    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    return if user_signed_in?

    error_message(title: t('concerns.sessions_management.unauthorized.signed_out.error.title'))

    redirect_to login_path
  end

  def logged_user_not_authorized
    error_message(title: t('concerns.sessions_management.unauthorized.signed_in.error.title'))

    redirect_to authorization_requests_path
  end
end
