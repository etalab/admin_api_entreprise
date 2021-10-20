class SessionsController < ApplicationController
  def new
    redirect_current_user_to_homepage if user_signed_in?
  end

  def create
    if user = User.find_by(email: authenticated_user_email)
      sign_in_and_redirect(user)
    else
      error_message(title: t('.not_found.title'), description: t('.not_found.description'))

      redirect_to login_path
    end
  end

  def destroy
    logout_user
    redirect_to root_path
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

  def authenticated_user_email
    auth_hash.try('info').try('email')
  end
end
