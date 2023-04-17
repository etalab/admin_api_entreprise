class APIEntreprise::UsersController < APIEntreprise::AuthenticatedUsersController
  def profile
    @user = current_user

    @user_roles = extract_roles_for_user(@user)
  end

  private

  def extract_roles_for_user(user)
    user.user_authorization_request_roles.pluck(:role).uniq
  end
end
