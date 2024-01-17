class AdminController < ApplicationController
  include AuthenticatedUserManagement

  before_action :user_is_admin?

  layout 'admin'

  private

  def user_is_admin?
    redirect_to_root unless true_user.admin?
  end
end
