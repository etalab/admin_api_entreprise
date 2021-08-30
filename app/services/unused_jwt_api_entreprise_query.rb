class UnusedJwtApiEntrepriseQuery
  def perform
    JwtApiEntreprise.where.not(id: used_jwt_ids)
  end

  def used_jwt_ids
    UsedJwtIdsElasticQuery.new.perform
  end
end
