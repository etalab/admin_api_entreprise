class Admin::UsersController < AdminController
  def index
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true).page(params[:page])
  end

  def impersonate
    user = User.find(params[:id])

    impersonate_user(user)

    redirect_to root_path
  end

  def stop_impersonating
    stop_impersonating_user

    redirect_to admin_users_path
  end
end
