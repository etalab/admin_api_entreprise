class JwtAPIEntrepriseController < AuthenticatedUsersController
  def index
    @tokens = current_user.jwt_api_entreprise
      .unexpired
      .not_blacklisted
      .where(archived: false)
  end

  def create_magic_link

  end
end
