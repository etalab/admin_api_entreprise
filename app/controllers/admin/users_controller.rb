class Admin::UsersController < AdminController
  def index
    @q = User.includes(:editor).ransack(params[:q])
    @users = @q.result(distinct: true).page(params[:page])
  end

  def edit
    @user = User.find(params[:id])
    @editors = Editor.all
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      success_message(title: "Utilisateur #{@user.email} a bien été modifié")

      redirect_to admin_users_path
    else
      render :edit
    end
  end

  def impersonate
    user = User.find(params[:id])

    impersonate_user(user)

    redirect_to authorization_requests_path
  end

  def stop_impersonating
    stop_impersonating_user

    redirect_to admin_users_path
  end

  private

  def user_params
    params.expect(user: [:editor_id])
  end
end
