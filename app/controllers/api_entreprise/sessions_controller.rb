class APIEntreprise::SessionsController < APIEntrepriseController
  def new
    redirect_current_user_to_homepage if user_signed_in?
  end

  def create
    login = APIEntreprise::User::Login.call(login_params)

    if login.success?
      sign_in_and_redirect(login.user)
    else
      error_message(title: t('.not_found.title'), description: t('.not_found.description'))

      redirect_to login_path
    end
  end

  def destroy
    logout_user
    redirect_to login_path
  end

  def failure
    error_message(title: t(".#{failure_message}", default: t('.unknown')))

    redirect_to login_path
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

  def failure_message
    params[:message]
  end

  def login_params
    {
      oauth_api_gouv_email: auth_hash.try('info').try('email'),
      oauth_api_gouv_id: auth_hash.try('info').try('sub')
    }
  end
end
