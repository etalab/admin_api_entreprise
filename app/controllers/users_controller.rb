class UsersController < AuthenticatedUsersController
  before_action :authorize_user!

  def show
    @user = User.find(params[:id])
  end
end
