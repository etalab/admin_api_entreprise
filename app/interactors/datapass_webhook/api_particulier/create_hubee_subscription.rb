class DatapassWebhook::APIParticulier::CreateHubEESubscription < ApplicationInteractor
  delegate :authorization_request, :hubee_organization_payload, :hubee_subscription_payload, to: :context

  def call
    context.hubee_subscription_payload = create_subscription_on_hubee
    save_hubee_subscription_id_to_authorization_request
  end

  private

  def create_subscription_on_hubee
    hubee_api_client.create_subscription(authorization_request, hubee_organization_payload, process_code, editor_payload)
  end

  def editor_organization
    @editor_organization ||= Organization.new(service_provider['siret'])
  end

  def editor_payload
    return {} unless editor_subscription?

    {
      delegationActor: {
        branchCode: editor_organization.code_commune_etablissement,
        companyRegister: editor_organization.siret,
        type: 'EDT'
      },
      accessMode: 'API'
    }
  end

  def editor_subscription?
    service_provider['type'] == 'editor'
  end

  def hubee_api_client
    @hubee_api_client ||= HubEEAPIClient.new
  end

  def process_code
    'FormulaireQF'
  end

  def save_hubee_subscription_id_to_authorization_request
    authorization_request.extra_infos['hubee_subscription_id'] = hubee_subscription_payload['id']
    authorization_request.save!
  end

  def service_provider
    @service_provider ||= Hash(authorization_request.extra_infos['service_provider'])
  end
end
