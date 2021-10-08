class Seeds
  def perform
    roles = create_roles

    user = create_user(email: 'user@yopmail.com')
    create_user(email: 'api-entreprise@yopmail.com', admin: true)

    create_token(user, roles.sample(2))
    create_token(user, roles.sample(2))
  end

  private

  def create_user(params={})
    User.create!(
      params,
    )
  end

  def create_roles
    %w[
      entreprises
      attestations_fiscales
      attestations_sociales
      actes_inpi
      associations
      probtp
      etablissements
    ].map do |code|
      Role.create!(
        name: code.humanize,
        code: code,
      )
    end
  end

  def create_token(user, roles)
    authorization_request = AuthorizationRequest.create!(
      user: user,
    )

    token = JwtAPIEntreprise.create!(
      JwtAPIEntreprise.default_create_params.merge(
        authorization_request: authorization_request,
      )
    )

    token.roles = roles

    token
  end
end
