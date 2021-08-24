class UsersWithRecentUnusedJwtApiEntrepriseQuery
  def perform
    recently_unused_jwt_api_entreprise =
      JwtApiEntreprise.includes(:user).
        where('created_at > ?', 1.week.ago.beginning_of_week).
        where.not(id: used_jwt_ids)

    recently_unused_jwt_api_entreprise.map(&:user).uniq
  end

  def used_jwt_ids
    UsedJwtIdsElasticQuery.new(number_of_days_from_now: 730).perform
  end
end
