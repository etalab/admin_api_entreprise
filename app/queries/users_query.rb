class UsersQuery
  def initialize(relation = User.all)
    @relation = relation

    self.relevent
  end

  def results
    @relation.all
  end

  def count
    @relation.count
  end

  def without_token
    @relation = @relation.left_outer_joins(:jwt_api_entreprise).
      where(jwt_api_entreprise: { id: nil })

    self
  end

  def with_token
    @relation = @relation.left_outer_joins(:jwt_api_entreprise).
      where.not(jwt_api_entreprise: { id: nil }).distinct

    self
  end

  def with_production_delayed_token
    production_delayed_token_ids = TokensQuery.new.production_delayed.results.pluck(:id)

    @relation = @relation.left_outer_joins(:jwt_api_entreprise).
      where(jwt_api_entreprise: { id: production_delayed_token_ids }).distinct

    self
  end


  def recently_created
    @relation = @relation.where('created_at > ?', 1.week.ago.beginning_of_week)

    self
  end

  def relevent
    @relation = @relation.where(admin: [nil, false])

    self
  end
end
