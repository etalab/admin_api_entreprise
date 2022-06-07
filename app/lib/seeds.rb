class Seeds
  def perform
    @scopes_entreprise = create_scopes_entreprise
    @scopes_particulier = create_scopes_particulier

    @user_email = 'user@yopmail.com'

    @user = create_main_user

    create_token_with_contact
    create_token_valid
    create_token_archived
    create_token_blacklisted
    create_token_expired
    create_authorization_refused
  end

  def flushdb
    raise 'Not in production!' if Rails.env.production?

    ActiveRecord::Base.connection.transaction do
      [
        User,
        AuthorizationRequest,
        Token,
        Contact
      ].each do |model_klass|
        model_klass.find_each do |model|
          model.destroy
        end
      end
    end
  end

  private

  def create_main_user
    create_user(
      email: @user_email,
      phone_number: '0936656565',
      first_name: 'Jean',
      last_name: 'Dupont'
    )
  end

  def create_token_with_contact
    token = create_token(@user, @scopes_entreprise.sample(2), authorization_request_params: {
      intitule: 'Mairie de Lyon',
      external_id: 51,
      status: :validated,
      first_submitted_at: 2.weeks.ago
    })
    create_contact(email: @user_email, authorization_request: token.authorization_request, contact_type: 'admin')
  end

  def create_token_valid
    create_token(@user, @scopes_entreprise.sample(2), authorization_request_params: {
      intitule: 'Mairie de Lyon 2',
      external_id: 52,
      status: :validated,
      first_submitted_at: 2.weeks.ago
    })
  end

  def create_token_archived
    create_token(@user, @scopes_entreprise.sample(2), token_params: { archived: true }, authorization_request_params: {
      intitule: 'Mairie de Strasbourg',
      external_id: 21,
      status: :validated,
      first_submitted_at: 1.week.ago
    })
  end

  def create_token_blacklisted
    create_token(@user, @scopes_entreprise.sample(2), token_params: { blacklisted: true }, authorization_request_params: {
      intitule: 'Mairie de Paris',
      external_id: 42,
      status: :validated,
      first_submitted_at: 1.week.ago
    })
  end

  def create_token_expired
    create_token(@user, @scopes_entreprise.sample(2),
      token_params: { exp: 1.year.ago, created_at: 2.years.ago + 1.week },
      authorization_request_params: {
        intitule: 'Mairie de Montpellier',
        external_id: 420,
        status: :validated,
        first_submitted_at: 2.years.ago,
        validated_at: 2.years.ago + 1.week
      })
  end

  def create_authorization_refused
    create_authorization_request(
      intitule: 'Mairie de Bruxelles',
      user: @user,
      status: :refused,
      external_id: 69,
      first_submitted_at: 2.years.ago,
      validated_at: 2.years.ago + 1.week
    )
  end

  def create_user(params = {})
    User.create!(params)
  end

  def create_scopes_particulier
    YAML
      .load_file(Rails.root.join('config/data/scopes/particulier.yml'))
      .map do |scope|
      Scope.create!(
        code: scope['code'],
        name: scope['name'],
        api: :particulier
      )
    end
  end

  def create_scopes_entreprise
    YAML
      .load_file(Rails.root.join('config/data/scopes/entreprise.yml'))
      .map do |scope|
      Scope.create!(
        code: scope['code'],
        name: scope['name'],
        api: :entreprise
      )
    end
  end

  def create_contact(params = {})
    Contact.create!(params)
  end

  def create_token(user, scopes, token_params: {}, authorization_request_params: {})
    authorization_request = create_authorization_request(authorization_request_params.merge(user:))

    token = Token.create!(
      Token.default_create_params
        .merge(token_params)
        .merge(
          authorization_request:
        )
    )

    token.update(scopes:)

    token
  end

  def create_authorization_request(params = {})
    AuthorizationRequest.create!(params)
  end
end
