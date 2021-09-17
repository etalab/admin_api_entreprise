class Api::PrivateMetricsController < ApiController
  skip_before_action :jwt_authenticate!

  def index
    #render json: {
    #  unused_tokens_list: TokensQuery.new.unused,
    #  tokens_expiring_in_less_than_1_week: tokens_expiring_in_less_than_1_week,
    #  tokens_expiring_in_less_than_1_month_but_after_1_week: tokens_expiring_in_less_than_1_month_but_after_1_week,
    #  tokens_expiring_in_less_than_3_months_but_after_1_month: tokens_expiring_in_less_than_3_months_but_after_1_month
    #}, status: 200
    @histogram = User.all.group_by{ |u| u.created_at.beginning_of_month }.map{ |d, results| [d.strftime('%Y-%m'), results.count] }
    render 'private_metrics/index'
  end

  def tokens_expiring_in_less_than_1_week
    TokensQuery.new.expiring_within_interval(
      interval_start: now,
      interval_stop: 1.week.from_now
    ).count
  end

  def tokens_expiring_in_less_than_1_month_but_after_1_week
    TokensQuery.new.expiring_within_interval(
      interval_start: 1.week.from_now.tomorrow,
      interval_stop: now + 1.month
    ).count
  end

  def tokens_expiring_in_less_than_3_months_but_after_1_month
    TokensQuery.new.expiring_within_interval(
      interval_start: 1.month.from_now.tomorrow,
      interval_stop: now + 3.month
    ).count
  end

  def now
    @now ||= Time.now
  end

  #new_users_histogram: User.all.group_by{ |u| u.created_at.beginning_of_month }.map{ |d, results| [d.strftime('%Y-%m'), results.count] },
  #active_jwt_count:
  #user_wiht_recent_unused_jwt_api_entreprise: JwtApiEntreprise.where.not(id: used_jti).where('created_at > ?', 1.week.ago.beginning_of_week).users.uniq,
end

