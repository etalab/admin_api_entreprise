class OAuthApiGouvLoginsController < ApplicationController
  skip_before_action :require_login

  def new
    redirect_current_user_to_homepage if current_user
  end

  def create
    if user = User.find_by(email: authenticated_user_email)
      create_login_session(user)
      redirect_current_user_to_homepage
    else
      redirect_to login_path
    end
  end

  def failure
    redirect_to login_path, notice: failure_message
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

  def failure_message
    params[:message].humanize
  end

  def authenticated_user_email
    auth_hash.try('info').try('email')
  end

  def create_login_session(user)
    session[:current_user_id] = user.id
  end

  def redirect_current_user_to_homepage
    if current_user.admin?
      redirect_to admin_users_path
    else
      redirect_to user_path(current_user)
    end
  end
end
