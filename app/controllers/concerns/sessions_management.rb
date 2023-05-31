module SessionsManagement
  def new
    redirect_current_user_to_homepage if user_signed_in?
  end

  def create_from_oauth
    interactor_call = oauth_login_organizer.call(oauth_params)

    login(interactor_call)
  end

  def failure
    error_message(title: t(".#{failure_message}", default: t('.unknown')))

    redirect_to login_path
  end

  def destroy
    logout_user
    redirect_to login_path
  end

  private

  def login(interactor_call)
    if interactor_call.success?
      sign_in_and_redirect(interactor_call.user)
    else
      error_message(title: t('.error.title'), description: t('.error.description'))

      redirect_to login_path
    end
  end

  def failure_message
    params[:message]
  end

  def oauth_params
    {
      oauth_api_gouv_email: auth_hash.try('info').try('email'),
      oauth_api_gouv_id: auth_hash.try('info').try('sub')
    }
  end

  def auth_hash
    request.env['omniauth.auth']
  end
end
