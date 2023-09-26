class Seeds
  def perform
    @user_email = 'user@yopmail.com'
    @user = create_main_user

    @contact_email = 'contact_technique@yopmail.com'
    @contact = create_contact

    create_data_for_api_entreprise
    create_data_for_api_particulier
    create_data_shared
  end

  def flushdb
    raise 'Not in production!' if Rails.env.production?

    load_all_models!

    ActiveRecord::Base.connection.transaction do
      ApplicationRecord.descendants.each(&:delete_all)
    end
  end

  def create_scopes(api)
    YAML.load_file(Rails.root.join("config/data/scopes/#{api}.yml"))
  end

  private

  def create_data_for_api_entreprise
    @scopes_entreprise = create_scopes('entreprise')

    create_api_entreprise_token_valid
    create_api_entreprise_token_archived
    create_api_entreprise_token_blacklisted
    create_api_entreprise_token_expired
    create_api_entreprise_authorization_refused
  end

  def create_data_for_api_particulier
    @scopes_particulier = create_scopes('particulier')

    create_api_particulier_token_valid
  end

  def create_data_shared
    create_magic_link
  end

  def create_main_user
    create_user(
      email: @user_email,
      first_name: 'Jean',
      last_name: 'Dupont'
    )
  end

  def create_contact
    create_user(
      email: @contact_email,
      first_name: 'Justine',
      last_name: 'Martin'
    )
  end

  def create_magic_link
    MagicLink.new(email: @user.email)
  end

  def create_api_entreprise_token_valid
    create_token(
      @scopes_entreprise.sample(2),
      'entreprise',
      demandeur: @user,
      contact_technique: @contact,
      authorization_request_params: {
        intitule: 'Mairie de Lyon 2',
        external_id: 102,
        status: :validated,
        first_submitted_at: 2.weeks.ago,
        siret: '012345678901234'
      }
    )
  end

  def create_api_entreprise_token_archived
    create_token(
      @scopes_entreprise.sample(2),
      'entreprise',
      token_params: { archived: true },
      demandeur: @user,
      contact_technique: @contact,
      authorization_request_params: {
        intitule: 'Mairie de Strasbourg',
        external_id: 103,
        status: :validated,
        first_submitted_at: 1.week.ago,
        siret: '012345678901235'
      }
    )
  end

  def create_api_entreprise_token_blacklisted
    create_token(
      @scopes_entreprise.sample(2),
      'entreprise',
      token_params: { blacklisted: true, exp: 14.months.ago },
      demandeur: @user,
      authorization_request_params: {
        intitule: 'Mairie de Paris',
        external_id: 104,
        status: :validated,
        first_submitted_at: 1.week.ago,
        siret: '012345678901236'
      }
    )
  end

  def create_api_entreprise_token_expired
    create_token(
      @scopes_entreprise.sample(2),
      'entreprise',
      token_params: { exp: 1.year.ago, created_at: 2.years.ago + 1.week },
      demandeur: @user,
      authorization_request_params: {
        intitule: 'Mairie de Montpellier',
        external_id: 105,
        status: :validated,
        api: 'entreprise',
        first_submitted_at: 2.years.ago,
        validated_at: 2.years.ago + 1.week,
        siret: '012345678901237'
      }
    )
  end

  def create_api_entreprise_authorization_refused
    create_user_authorization_request_role(
      user: @user,
      authorization_request: create_authorization_request(
        api: 'entreprise',
        intitule: 'Mairie de Bruxelles',
        status: :refused,
        external_id: 106,
        first_submitted_at: 2.years.ago,
        validated_at: 2.years.ago + 1.week
      ),
      role: 'demandeur'
    )
  end

  def create_api_particulier_token_valid
    create_token(
      @scopes_particulier,
      'particulier',
      demandeur: @user,
      contact_metier: @contact,
      contact_technique: @contact,
      authorization_request_params: {
        intitule: 'Mairie de Bordeaux',
        external_id: 201,
        status: :validated,
        first_submitted_at: 2.weeks.ago
      }
    )
  end

  def create_user(params = {})
    User.create!(params)
  end

  # rubocop:disable Metrics/ParameterLists
  def create_token(scopes, api, demandeur:, contact_technique: nil, contact_metier: nil, token_params: {}, authorization_request_params: {})
    authorization_request = create_authorization_request(authorization_request_params.merge(api:))

    create_user_authorization_request_role(user: demandeur, authorization_request:, role: 'demandeur')
    create_user_authorization_request_role(user: contact_technique, authorization_request:, role: 'contact_technique') if contact_technique
    create_user_authorization_request_role(user: contact_metier, authorization_request:, role: 'contact_metier') if contact_metier

    Token.create!(
      Token.default_create_params
        .merge(token_params)
        .merge(scopes:)
        .merge(
          authorization_request:
        )
    )
  end
  # rubocop:enable Metrics/ParameterLists

  def create_authorization_request(params = {})
    AuthorizationRequest.create!(params)
  end

  def create_user_authorization_request_role(params = {})
    UserAuthorizationRequestRole.create!(params)
  end

  def load_all_models!
    Dir[Rails.root.join('app/models/**/*.rb')].each { |f| require f }
  end
end
