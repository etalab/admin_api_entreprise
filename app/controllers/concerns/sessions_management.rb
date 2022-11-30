module SessionsManagement
  def new
    redirect_current_user_to_homepage if user_signed_in?
  end

  def create
    @magic_link = MagicLink.where(access_token:).last

    if valid_user_magic_link?
      sign_in_and_redirect(user)
    else
      error_message(title: t('.error.title'), description: t('.error.description'))

      redirect_to login_path
    end
  end

  def destroy
    logout_user
    redirect_to login_path
  end

  private

  def valid_user_magic_link?
    @magic_link && user.present? && !@magic_link.expired?
  end

  def user
    User.find_by(email: @magic_link.email)
  end

  def access_token
    params.require(:access_token)
  end
end
