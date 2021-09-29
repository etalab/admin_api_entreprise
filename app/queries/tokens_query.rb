class TokensQuery
  def initialize(relation = JwtAPIEntreprise.all)
    @relation = relation

    self.relevant
  end

  def results
    @relation.all
  end

  def count
    @relation.count
  end

  def expiring_within_interval(interval_start:, interval_stop:)
    interval_range = (interval_start.beginning_of_day.to_i..interval_stop.end_of_day.to_i)

    @relation = @relation.where(exp: interval_range)

    self
  end

  def unused
    used_jwt_ids = UsedJwtIdsElasticQuery.new.perform

    @relation = @relation.where.not(id: used_jwt_ids)

    self
  end

  def recently_created
    @relation = @relation.where('created_at > ?', 1.week.ago.beginning_of_week)

    self
  end

  def relevant
    @relation = @relation.
      where(archived: [nil, false]).
      where(blacklisted: [nil, false]).
      where('exp > ?', Time.zone.now.to_i).
      where.not('subject LIKE ?','%UptimeRobot%')

    self
  end

  def production_delayed
    @relation = @relation.
      where('created_at < ?', 30.day.ago).
      where(id: NotInProductionJwtIdsElasticQuery.new.perform)

    self
  end
end
