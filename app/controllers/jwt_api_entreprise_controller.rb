class JwtAPIEntrepriseController < AuthenticatedUsersController
  before_action { authorize_user_resource_access!(user_resource_id) }

  def index
    @tokens = current_user.jwt_api_entreprise
      .unexpired
      .not_blacklisted
      .where(archived: false)
  end

  private

  def user_resource_id
    params[:user_id]
  end
end
