class UsersController < AuthenticatedUsersController
  def profile
    @user = current_user
  end
end
