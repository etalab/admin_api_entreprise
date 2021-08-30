class UsersWithJwtApiEntrepriseQuery
  def perform
    User.left_outer_joins(:jwt_api_entreprise).where.not(jwt_api_entreprise: { id: nil }).uniq
  end
end
