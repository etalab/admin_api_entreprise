class AuthenticatedAdminsController < AuthenticatedUsersController
  before_action :authenticate_admin!

  private

  def authenticate_admin!
    redirect_to user_path(current_user) unless current_user.admin?
  end
end
