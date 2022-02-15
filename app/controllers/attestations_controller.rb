class AttestationsController < AuthenticatedUsersController
  def index
    @user = current_user
  end
end
