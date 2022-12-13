module SessionsManagement
  def new
    redirect_current_user_to_homepage if user_signed_in?
  end

  def create
    interactor_call = MagicLink::ValidateUserFromAccessToken.call(access_token: params.require(:access_token))

    if interactor_call.success?
      sign_in_and_redirect(interactor_call.user)
    else
      error_message(title: t('.error.title'), description: t('.error.description'))

      redirect_to login_path
    end
  end

  def destroy
    logout_user
    redirect_to login_path
  end
end
