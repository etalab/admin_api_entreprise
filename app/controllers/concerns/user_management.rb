module UserManagement
  def profile
    @user_roles = extract_roles_for_user

    render 'shared/users/profile'
  end

  private

  def extract_roles_for_user
    current_user.user_authorization_request_roles.pluck(:role).uniq.map(&:to_sym)
  end
end
