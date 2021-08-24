class UnusedJwtApiEntrepriseQuery
  def initialize(number_of_days_from_now: 730)
    @number_of_days_from_now = number_of_days_from_now
  end

  def perform
    JwtApiEntreprise.where.not(id: used_jwt_ids)
  end

  def used_jwt_ids
    UsedJwtIdsElasticQuery.new(number_of_days_from_now: @number_of_days_from_now).perform
  end
end
