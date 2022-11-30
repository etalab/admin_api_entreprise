module SessionsManagement
  def new
    redirect_current_user_to_homepage if user_signed_in?
  end

  def destroy
    logout_user
    redirect_to login_path
  end
end
