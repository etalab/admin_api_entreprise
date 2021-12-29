class Seeds
  def perform
    roles = create_roles

    user_email = 'user@yopmail.com'
    user = create_user(
      email: user_email,
      phone_number: '0936656565',
      first_name: 'Jean',
      last_name: 'Dupont',
    )

    create_user(
      email: 'api-entreprise@yopmail.com',
      phone_number: '0836656565',
      admin: true,
    )

    token = create_token(user, roles.sample(2), authorization_request_params: {
      intitule: 'Mairie de Lyon',
      external_id: 51,
      status: :validated,
      first_submitted_at: 2.weeks.ago,
    })
    create_contact(email: user_email, authorization_request: token.authorization_request, contact_type: 'admin')

    create_token(user, roles.sample(2), authorization_request_params: {
      intitule: 'Mairie de Paris',
      external_id: 42,
      status: :validated,
      first_submitted_at: 1.week.ago,
    })

    create_authorization_request(
      intitule: 'Mairie de Bruxelles',
      user: user,
      status: :refused,
      external_id: 69,
      first_submitted_at: 2.years.ago,
      validated_at: 2.years.ago + 1.week,
    )
  end

  private

  def create_user(params={})
    User.create!(params)
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

  def create_contact(params={})
    Contact.create!(params)
  end

  def create_token(user, roles, authorization_request_params: {})
    authorization_request = create_authorization_request(authorization_request_params.merge(user: user))

    token = JwtAPIEntreprise.create!(
      JwtAPIEntreprise.default_create_params.merge(
        authorization_request: authorization_request,
      )
    )

    token.roles = roles

    token
  end

  def create_authorization_request(params={})
    AuthorizationRequest.create!(params)
  end
end
