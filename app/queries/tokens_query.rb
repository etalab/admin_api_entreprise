class TokensQuery
  def initialize(relation = JwtApiEntreprise.all)
    @relation = relation
  end

  def expiring_within_interval(interval_start:, interval_stop:)
    interval_range = (interval_start.beginning_of_day.to_i..interval_stop.end_of_day.to_i)

    @relation.where(exp: interval_range)
  end

  def unused
    used_jwt_ids = UsedJwtIdsElasticQuery.new.perform

    @relation.where.not(id: used_jwt_ids)
  end

  def recently_created
    @relation.where('created_at > ?', 1.week.ago.beginning_of_week)
  end
end
