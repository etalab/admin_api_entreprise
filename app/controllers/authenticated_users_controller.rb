class AuthenticatedUsersController < ApplicationController
  before_action :authenticate_user!

  private

  def authenticate_user!
    unless user_signed_in?
      redirect_to login_path, alert: 'Veuillez vous connecter pour accéder à cette page.'
    end
  end
end
