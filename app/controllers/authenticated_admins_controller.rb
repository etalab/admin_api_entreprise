class AuthenticatedAdminsController < AuthenticatedUsersController
  before_action :authenticate_admin!

  layout 'application'

  private

  def authenticate_admin!
    redirect_current_user_to_homepage unless current_user.admin?
  end
end
