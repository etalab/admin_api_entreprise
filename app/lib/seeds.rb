class Seeds
  def perform
    @user_email = 'user@yopmail.com'
    @user = create_main_user

    @contact_email = 'contact_technique@yopmail.com'
    @contact = create_contact

    create_editor
    create_provider_user
    create_data_for_api_entreprise
    create_data_for_api_particulier
    create_data_shared
    create_audit_notifications
    create_oauth2_test_data
  end

  def flushdb
    raise 'Not in production!' if Rails.env.production?

    load_all_models!

    ProlongTokenWizard.destroy_all

    ActiveRecord::Base.connection.transaction do
      ApplicationRecord.descendants.each(&:delete_all)
      AccessLog.delete_all
    end
  end

  def create_scopes(api)
    YAML.load_file(Rails.root.join("config/data/scopes/#{api}.yml"))
  end

  def create_oauth2_test_data
    ar = create_authorization_request(
      external_id: '9001',
      intitule: 'Test OAuth2 Authorization Request',
      status: 'validated',
      api: 'entreprise',
      siret: '13002526500013',
      scopes: %w[unites_legales_etablissements_insee associations_djepva],
      validated_at: Time.current,
      first_submitted_at: Time.current
    )

    Token.create!(
      authorization_request: ar,
      iat: Time.current.to_i,
      exp: 18.months.from_now.to_i,
      version: '1.0',
      scopes: ar.scopes
    )

    editor = Editor.find_by!(name: 'UMAD Corp')
    oauth_app = OAuthApplication.create!(
      name: "OAuth - #{editor.name}",
      owner: editor,
      uid: 'oauth-test-client-id',
      secret: 'oauth-test-client-secret'
    )
    editor.update!(oauth_application: oauth_app)

    EditorDelegation.create!(editor:, authorization_request: ar)
  end

  private

  def create_data_for_api_entreprise
    @scopes_entreprise = create_scopes('entreprise')

    create_api_entreprise_token_valid
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

  def create_editor
    editor = Editor.create!(
      name: 'UMAD Corp',
      form_uids: %w[umadcorp-form-api-entreprise umadcorp-form-api-particulier],
      copy_token: true
    )
    create_user(
      email: 'editeur@yopmail.com',
      first_name: 'Edouard',
      last_name: 'Lefevre',
      editor: editor
    )
  end

  def create_provider_user
    create_user(
      email: 'user10@yopmail.com',
      first_name: 'Michel',
      last_name: 'Paul',
      provider_uids: %w[insee dgfip]
    )
  end

  def create_magic_link
    MagicLink.create!(email: @user.email)
  end

  def create_api_entreprise_token_valid
    create_token(
      %w[open_data unites_legales_etablissements_insee attestation_sociale_urssaf attestation_fiscale_dgfip],
      'entreprise',
      token_params: { id: '00000000-0000-0000-0000-000000000000' },
      demandeur: @user,
      contact_technique: @contact,
      authorization_request_params: {
        intitule: 'Mairie de Lyon 2',
        external_id: 102,
        status: :validated,
        first_submitted_at: 2.weeks.ago,
        demarche: 'umadcorp-form-api-entreprise',
        siret: '12000101100010'
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
        siret: '21670482500019'
      }
    )
  end

  def create_api_entreprise_token_blacklisted
    create_token(
      @scopes_entreprise.sample(2),
      'entreprise',
      token_params: { blacklisted_at: 6.months.ago, exp: 14.months.ago },
      demandeur: @user,
      authorization_request_params: {
        intitule: 'Mairie de Paris',
        external_id: 104,
        status: :validated,
        first_submitted_at: 1.week.ago,
        siret: '21750001600019'
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
        siret: '21340172201787'
      }
    )
  end

  def create_api_entreprise_authorization_refused
    create_user_authorization_request_role(
      user: @user,
      authorization_request: create_authorization_request(
        api: 'entreprise',
        intitule: 'Mairie de Bruges',
        status: :refused,
        external_id: 106,
        first_submitted_at: 2.years.ago,
        validated_at: 2.years.ago + 1.week,
        siret: '21330075900015'
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
        demarche: 'umadcorp-form-api-particulier',
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

    token = Token.create!(
      Token.default_create_params
        .merge(token_params)
        .merge(scopes:)
        .merge(
          authorization_request:
        )
    )

    create_access_logs_for_token(token) unless AccessLog.new.readonly?
  end
  # rubocop:enable Metrics/ParameterLists

  def create_access_logs_for_token(token)
    [
      Time.zone.now,
      3.hours.ago,
      1.day.ago,
      2.days.ago,
      3.days.ago,
      8.days.ago
    ].each do |timestamp|
      AccessLog.create!(
        path: '/api/v3/what/ever',
        request_id: SecureRandom.uuid,
        token:,
        timestamp:
      )
    end
  end

  def create_authorization_request(params = {})
    find_or_create_organization(params[:siret]) if params[:siret]
    AuthorizationRequest.create!(params)
  end

  def find_or_create_organization(siret)
    organization = Organization.find_by(siret:)

    return organization if organization

    Organization.create!(
      siret:,
      insee_payload: JSON.parse(Rails.root.join("spec/fixtures/insee/#{siret}.json").read)
    )
  end

  def create_user_authorization_request_role(params = {})
    UserAuthorizationRequestRole.create!(params)
  end

  # rubocop:disable Metrics/AbcSize
  def create_audit_notifications
    authorization_requests = AuthorizationRequest.where.not(siret: nil).includes(:tokens).limit(3)

    authorization_requests.each_with_index do |auth_request, index|
      next unless auth_request.tokens.any?

      access_logs = AccessLog.joins(:token)
        .where(tokens: { authorization_request: auth_request })
        .limit(2 + index)

      next if access_logs.empty?

      AuditNotification.create!(
        authorization_request_external_id: auth_request.external_id,
        request_id_access_logs: access_logs.pluck(:request_id),
        contact_emails: [auth_request.demandeur&.email, auth_request.contact_technique&.email].compact.uniq,
        approximate_volume: 9001 + index,
        reason: [
          'Contrôle de routine - vérification des logs d\'accès',
          'Audit sécurité - activité suspecte détectée',
          'Investigation - paramètres incorrects dans les requêtes'
        ][index % 3]
      )
    end
  end
  # rubocop:enable Metrics/AbcSize

  def load_all_models!
    Rails.root.glob('app/models/**/*.rb').each { |f| require f }
  end
end
