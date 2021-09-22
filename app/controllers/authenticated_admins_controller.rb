class AuthenticatedAdminsController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    redirect_to user_path(current_user) unless current_user.admin?
  end
end
