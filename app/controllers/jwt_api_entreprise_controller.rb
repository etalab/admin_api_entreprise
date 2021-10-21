class JwtAPIEntrepriseController < AuthenticatedUsersController
  def index
    @tokens = current_user.jwt_api_entreprise
      .unexpired
      .not_blacklisted
      .where(archived: false)
  end

  def stats
    @token = JwtAPIEntreprise.find(params[:id])
  end
end
