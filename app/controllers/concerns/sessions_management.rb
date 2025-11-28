module SessionsManagement
  def new
    redirect_current_user_to_homepage if user_signed_in?
  end

  def create_from_oauth
    interactor_call = User::ProconnectLogin.call(user_params:)

    login(interactor_call)
  end

  def failure
    error_message(title: t(".#{failure_message}", default: t('.unknown')))

    redirect_to login_path
  end

  def destroy
    logout_user

    redirect_to after_logout_path,
      allow_other_host: true
  end

  def after_logout
    success_message(title: t('.success'))

    redirect_to root_path
  end

  private

  def after_logout_path
    "/auth/proconnect_#{namespace}/logout"
  end

  def user_params
    request.env['omniauth.auth'].info.slice('email', 'last_name', 'first_name', 'uid')
  end

  def login(interactor_call)
    if interactor_call.success?
      sign_in_and_redirect(interactor_call.user)
    else
      send(extract_flash_kind(interactor_call.message), title: t(".#{interactor_call.message}.title"), description: t(".#{interactor_call.message}.description", email: oauth_email))

      redirect_to login_path
    end
  end

  def failure_message
    params[:message]
  end

  def extract_flash_kind(message)
    case message
    when 'not_found'
      'info_message'
    else
      'error_message'
    end
  end
end
