class TokensQuery
  def initialize(relation = JwtApiEntreprise.all)
    @relation = relation
  end

  def expiring_within_interval(interval_start:, interval_stop:)
    interval_range = (interval_start.beginning_of_day.to_i..interval_stop.end_of_day.to_i)

    @relation.where(exp: interval_range)
  end
end
