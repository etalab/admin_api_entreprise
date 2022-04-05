class AuthenticatedUsersController < ApplicationController
  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :logged_user_not_authorized

  layout 'authenticated_user'

  private

  def authenticate_user!
    unless user_signed_in?
      error_message(title: t('sessions.unauthorized.error.title'))

      redirect_to login_path
    end
  end

  def logged_user_not_authorized
    redirect_to user_profile_path
  end
end
