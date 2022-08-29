class APIParticulier::UsersController < APIParticulier::AuthenticatedUsersController
  def profile
    @tokens = current_user.tokens.valid_for('particulier')
  end
end
