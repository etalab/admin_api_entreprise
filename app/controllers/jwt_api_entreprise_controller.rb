class JwtAPIEntrepriseController < AuthenticatedUsersController
  before_action { authorize_user_resource_access!(user_resource_id) }

  def index

  end

  private

  def user_resource_id
    params[:user_id]
  end
end
