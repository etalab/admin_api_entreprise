class Admin::UsersController < AuthenticatedAdminsController
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_admin!

  def index
    @users = User.all
  end

  def show
    @user = User.find(user_params[:id])
  end

  def user_params
    params.permit(:id)
  end
end
