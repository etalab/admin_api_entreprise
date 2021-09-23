class SessionsController < AuthenticatedUsersController
  skip_before_action :authenticate_user!

  def new
    redirect_current_user_to_homepage if user_signed_in?
  end

  def create
    if user = User.find_by(email: authenticated_user_email)
      sign_in_and_redirect(user)
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
    params[:message]
  end

  def authenticated_user_email
    auth_hash.try('info').try('email')
  end
end
