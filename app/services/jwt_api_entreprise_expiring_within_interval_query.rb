class JwtApiEntrepriseExpiringWithinIntervalQuery
  def initialize(interval_start:, interval_stop:)
    @interval_start = interval_start
    @interval_stop  = interval_stop
  end

  def perform
    JwtApiEntreprise.where('exp >= ? AND exp <= ?',
                           @interval_start.beginning_of_day.to_i,
                           @interval_stop.end_of_day.to_i
                          )
  end
end
