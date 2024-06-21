class HubEEAPIClient < AbstractHubEEAPIClient
  class NotFound < StandardError; end
  class AlreadyExists < StandardError; end

  def find_organization(organization)
    http_connection.get("#{host}/referential/v1/organizations/SI-#{organization.siret}-#{organization.code_commune_etablissement}").body
  rescue Faraday::ResourceNotFound
    raise NotFound
  end

  def create_organization(organization, email)
    http_connection.post(
      "#{host}/referential/v1/organizations",
      {
        type: 'SI',
        companyRegister: organization.siret,
        branchCode: organization.code_commune_etablissement,
        email:,
        name: organization.denomination,
        postalCode: organization.code_postal_etablissement,
        territory: organization.code_commune_etablissement,
        status: 'Actif'
      }.to_json,
      'Content-Type' => 'application/json'
    )
  rescue Faraday::BadRequestError => e
    raise AlreadyExists if already_exists_error?(e)

    raise
  end

  def create_subscription(authorization_request, organization_payload, process_code)
    http_connection.post(
      "#{host}/referential/v1/subscriptions",
      {
        datapassId: authorization_request.external_id.to_i,
        notificationFrequency: 'unitaire',
        processCode: process_code,
        subscriber: {
          type: 'SI',
          companyRegister: organization_payload['companyRegister'],
          branchCode: organization_payload['branchCode']
        },
        email: authorization_request.demandeur.email,
        status: 'Actif',
        localAdministrator: {
          email: authorization_request.demandeur.email
        }
      }.to_json,
      'Content-Type' => 'application/json'
    )
  rescue Faraday::BadRequestError => e
    raise AlreadyExists if already_exists_error?(e)

    raise
  end

  protected

  def host
    Rails.application.credentials.hubee_api_url
  end

  def already_exists_error?(faraday_error)
    faraday_error.response[:body]['errors'].any? do |error|
      error['message'].include?('already exists')
    end
  end

  def http_connection
    super do |conn|
      conn.request :authorization, 'Bearer', -> { HubEEAPIAuthentication.new.access_token }
    end
  end
end
