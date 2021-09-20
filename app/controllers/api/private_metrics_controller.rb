class API::PrivateMetricsController < APIController
  skip_before_action :jwt_authenticate!

  def index
    #render json: {
    #  unused_tokens_list: TokensQuery.new.unused,
    #  tokens_expiring_in_less_than_1_week: tokens_expiring_in_less_than_1_week,
    #  tokens_expiring_in_less_than_1_month_but_after_1_week: tokens_expiring_in_less_than_1_month_but_after_1_week,
    #  tokens_expiring_in_less_than_3_months_but_after_1_month: tokens_expiring_in_less_than_3_months_but_after_1_month
    #}, status: 200
    @histogram = User.all.group_by{ |u| u.created_at.beginning_of_month }.map{ |d, results| [d.strftime('%Y-%m'), results.count] }

    @tokens_expiring_in_less_than_1_week = tokens_expiring_in_less_than_1_week
    @tokens_expiring_in_less_than_1_month_but_after_1_week = tokens_expiring_in_less_than_1_month_but_after_1_week
    @tokens_expiring_in_less_than_3_months_but_after_1_month = tokens_expiring_in_less_than_3_months_but_after_1_month
    @tokens_expiring_in_more_than_3_months = tokens_expiring_in_more_than_3_months

    @users_with_token = UsersQuery.new.with_token.count
    @users_without_token = UsersQuery.new.without_token.count
    @tokens_active_this_month = UsedJwtIdsElasticQuery.new(30).perform.count
    @tokens_inactive_this_month = JwtApiEntreprise.all.count - @tokens_active_this_month

		@users_recently_created = UsersQuery.new.recently_created
    # TODO : we have a naive expectation here : all tokens are not "valid", ie they can be archived / blacklisted
    # we could achieve that with additional explicit scoping in UsersQuery or default scoping

  	@users_with_recent_unused_token = TokensQuery.new.unused.recently_created.users.uniq
    render 'private_metrics/index'
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
    JwtApiEntreprise.all.count - TokensQuery.new.expiring_within_interval(
      interval_start: now,
      interval_stop: now + 3.month
    ).count
  end

  def now
    @now ||= Time.now
  end

  #new_users_histogram: User.all.group_by{ |u| u.created_at.beginning_of_month }.map{ |d, results| [d.strftime('%Y-%m'), results.count] },
  #active_jwt_count:
end

