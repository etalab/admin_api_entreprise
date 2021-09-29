class AuthenticatedUsersController < ApplicationController
  before_action :authenticate_user!

  private

  def authenticate_user!
    unless user_signed_in?
      redirect_to login_path, alert: 'Veuillez vous connecter pour accéder à cette page.'
    end
  end

  def authorize_user_resource_access!(user_id)
    redirect_current_user_to_homepage unless own_user_resource?(user_id)
  end

  def own_user_resource?(user_id)
    current_user.id == user_id
  end
end
