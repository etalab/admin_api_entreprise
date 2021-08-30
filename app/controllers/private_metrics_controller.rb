class PrivateMetricsController < ApplicationController
  skip_before_action :jwt_authenticate!

  def index
    render json: {
      unused_jwt_list: UnusedJwtApiEntrepriseQuery.new.perform,
      jwt_expiring_in_less_than_1_week: jwt_expiring_in_less_than_1_week,
      jwt_expiring_in_less_than_1_month_but_after_1_week: jwt_expiring_in_less_than_1_month_but_after_1_week,
      jwt_expiring_in_less_than_3_months_but_after_1_month: jwt_expiring_in_less_than_3_months_but_after_1_month
    }, status: 200
  end

  def jwt_expiring_in_less_than_1_week
    JwtApiEntrepriseExpiringWithinIntervalQuery.new(
      interval_start: now,
      interval_stop: 1.week.from_now
    ).perform.count
  end

  def jwt_expiring_in_less_than_1_month_but_after_1_week
    JwtApiEntrepriseExpiringWithinIntervalQuery.new(
      interval_start: 1.week.from_now.tomorrow,
      interval_stop: now + 1.month
    ).perform.count
  end

  def jwt_expiring_in_less_than_3_months_but_after_1_month
    JwtApiEntrepriseExpiringWithinIntervalQuery.new(
      interval_start: 1.month.from_now.tomorrow,
      interval_stop: now + 3.month
    ).perform.count
  end

  def now
    @now ||= Time.now
  end

  #new_users_histogram: User.all.group_by{ |u| u.created_at.beginning_of_month }.map{ |d, results| [d.strftime('%Y-%m'), results.count] },
  #active_jwt_count:
  #user_wiht_recent_unused_jwt_api_entreprise: JwtApiEntreprise.where.not(id: used_jti).where('created_at > ?', 1.week.ago.beginning_of_week).users.uniq,
end

