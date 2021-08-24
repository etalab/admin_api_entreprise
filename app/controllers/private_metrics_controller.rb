class PrivateMetricsController < ApplicationController
  skip_before_action :jwt_authenticate!

  def index
    all_jwt = JwtApiEntreprise.all

    render json: {
      unused_jwt_list: UnusedJwtApiEntrepriseQuery.new.perform,
      #active_jwt_count: JwtApiEntreprise.where(id: used_jti).count,
      #new_users_histogram: User.all.group_by{ |u| u.created_at.beginning_of_month }.map{ |d, results| [d.strftime('%Y-%m'), results.count] },
      #user_wiht_fresh_token_not_used_even_though_it_was_before_last_week: JwtApiEntreprise.where.not(id: used_jti).where('created_at > ?', 1.week.ago.beginning_of_week).users.uniq,
      #jwt_expiring_in_less_than_a_week:  JwtApiEntreprise.where('exp < ? AND exp > ?', Time.now.to_i + 1.week, Time.now.to_i),
      #jwt_expiring_in_less_than_three_months_but_after_month:  JwtApiEntreprise.where('exp < ? AND exp > ?', Time.now.to_i + 3.month, Time.now.to_i + 1.month),
      #jwt_expiring_in_less_than_a_month_but_after_1_week:  JwtApiEntreprise.where('exp < ? AND exp > ?', Time.now.to_i + 1.month, Time.now.to_i + 1.week)

    }, status: 200
  end
end

