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

    redirect_to oauth_logout_url
  end

  def after_logout
    success_message(title: t('.success'))

    redirect_to root_path
  end

  private

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

  def oauth_email
    auth_hash.try('info').try('email')
  end

  def oauth_params
    {
      oauth_api_gouv_id: auth_hash.try('info').try('sub'),
      oauth_api_gouv_email: oauth_email,
      oauth_api_gouv_info: auth_hash.try('info')
    }
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def oauth_logout_url
    "#{Rails.application.config.oauth_api_gouv_issuer}/oauth/logout?post_logout_redirect_uri=#{after_logout_url}&client_id=#{oauth_api_gouv_client_id}"
  end

  def oauth_api_gouv_client_id
    Rails.configuration.public_send("oauth_api_gouv_client_id_#{namespace.gsub('api_', '')}")
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
