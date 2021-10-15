class Admin::UsersController < AuthenticatedAdminsController
  def index
    @users = User.all
  end
end
