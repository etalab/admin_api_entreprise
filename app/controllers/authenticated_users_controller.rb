class AuthenticatedUsersController < ApplicationController
  before_action :authenticate_user!

  private

  def authenticate_user!
    unless user_signed_in?
      redirect_to login_path, alert: 'Veuillez vous connecter pour accéder à cette page.'
    end
  end

  def authorize_user!
    unless own_user_resource?
      redirect_current_user_to_homepage
    end
  end

  def own_user_resource?
    current_user.id == params[:id]
  end
end
