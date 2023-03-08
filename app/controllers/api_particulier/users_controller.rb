class APIParticulier::UsersController < APIParticulier::AuthenticatedUsersController
  def profile
    @tokens = current_user.tokens.active_for('particulier')
  end
end
