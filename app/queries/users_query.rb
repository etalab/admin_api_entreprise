class UsersQuery
  def initialize(relation = User.all)
    @relation = relation

    self.relevant
  end

  def results
    @relation.all
  end

  def count
    @relation.count
  end

  def with_token
    @relation = @relation.where(id: with_token_ids)

    self
  end

  def with_token_ids
    User.joins(:authorization_requests).joins(:jwt_api_entreprise).pluck('users.id').uniq
  end

  def without_token
    @relation = @relation.where.not(id: with_token_ids)

    self
  end

  def users_with_only_orphan_authorization_requests
    User.where.not(id: with_token_ids).joins(:authorization_requests).where.missing(:jwt_api_entreprise).pluck('users.id').uniq
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

  def relevant
    @relation = @relation.where(admin: [nil, false])

    self
  end
end
