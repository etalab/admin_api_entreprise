class APIEntreprise::UsersController < APIEntreprise::AuthenticatedUsersController
  def profile
    @user = current_user
  end
end
