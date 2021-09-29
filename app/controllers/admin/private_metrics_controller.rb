class Admin::PrivateMetricsController < AuthenticatedAdminsController
  def index
    @histogram = User.all.group_by{ |u| u.created_at.beginning_of_month }.map{ |d, results| [d.strftime('%Y-%m'), results.count] }

    @tokens_expiring_in_less_than_1_week = tokens_expiring_in_less_than_1_week
    @tokens_expiring_in_less_than_1_month_but_after_1_week = tokens_expiring_in_less_than_1_month_but_after_1_week
    @tokens_expiring_in_less_than_3_months_but_after_1_month = tokens_expiring_in_less_than_3_months_but_after_1_month
    @tokens_expiring_in_more_than_3_months = tokens_expiring_in_more_than_3_months

    @users_with_token = UsersQuery.new.with_token.count
    @users_without_token = UsersQuery.new.without_token.count
    @tokens_active_this_month = UsedJwtIdsElasticQuery.new(30).perform.count
    @tokens_inactive_this_month = JwtAPIEntreprise.all.count - @tokens_active_this_month

    @users_recently_created = UsersQuery.new.recently_created.results

    @users_with_recent_unused_token = User.left_outer_joins(:jwt_api_entreprise).where(jwt_api_entreprise: { id: TokensQuery.new.unused.recently_created.results }).distinct
    @users_with_production_delayed_token = UsersQuery.new.with_production_delayed_token.results

    render 'private_metrics/index', layout: 'application'
  end

  def tokens_expiring_in_less_than_1_week
    TokensQuery.new.expiring_within_interval(
      interval_start: now,
      interval_stop: now + 1.week
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

  def tokens_expiring_in_more_than_3_months
    JwtAPIEntreprise.all.count - TokensQuery.new.expiring_within_interval(
      interval_start: now,
      interval_stop: now + 3.month
    ).count
  end

  def now
    @now ||= Time.now
  end
end

