class AuthenticatedUsersController < ApplicationController
  before_action :authenticate_user!

  layout 'authenticated_user'

  private

  def authenticate_user!
    unless user_signed_in?
      error_message(title: t('sessions.unauthorized.error.title'))

      redirect_to login_path
    end
  end
end
