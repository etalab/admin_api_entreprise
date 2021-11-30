class Admin::UsersController < AuthenticatedAdminsController
  def index
    @users = User.all
  end

  def show
    @user = User.includes(:jwt_api_entreprise).find(params[:id])
    @active_jwt = @user.jwt_api_entreprise.filter do |token|
      !token.archived? && !token.blacklisted?
    end
    @archived_jwt = @user.jwt_api_entreprise.filter do |token|
      token.archived? && !token.blacklisted?
    end
    @blacklisted_jwt = @user.jwt_api_entreprise.filter(&:blacklisted)
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_update_params)
      success_message(title: t('.success'))
    else
      error_message(title: t('.error'))
    end

    redirect_to admin_user_url(@user)
  end

  private

  def user_update_params
    params.require(:user).permit(:note)
  end
end
