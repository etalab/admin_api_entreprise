class UsersQuery
  def initialize(relation = User.all)
    @relation = relation
  end

  def without_token
    @relation.left_outer_joins(:jwt_api_entreprise).
      where(jwt_api_entreprise: { id: nil })
  end

  def with_token
    @relation.left_outer_joins(:jwt_api_entreprise).
      where.not(jwt_api_entreprise: { id: nil }).uniq
  end

  def recently_created
    @relation.where('created_at > ?', 1.week.ago.beginning_of_week)
  end
end
