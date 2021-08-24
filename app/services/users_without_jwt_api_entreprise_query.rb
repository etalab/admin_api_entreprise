class UsersWithoutJwtApiEntrepriseQuery
  def perform
    User.left_outer_joins(:jwt_api_entreprise).where(jwt_api_entreprise: { id: nil})
  end
end
