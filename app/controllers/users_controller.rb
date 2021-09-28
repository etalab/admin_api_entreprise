class UsersController < AuthenticatedUsersController
  before_action :authorize_user!

  def show

  end
end
