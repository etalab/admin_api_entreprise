class CreateFormulaireQFHubEESubscriptionJob < ApplicationJob
  def perform(authorization_request_id)
    authorization_request = AuthorizationRequest.find(authorization_request_id)

    hubee_organization_payload = find_or_create_organization_on_hubee(authorization_request)

    authorization_request.extra_infos['hubee_organization_id'] = build_hubee_organization_id(hubee_organization_payload)
    authorization_request.save!

    create_subscription_on_hubee(authorization_request, hubee_organization_payload)
  rescue ActiveRecord::RecordNotFound
    # do nothing
  end

  private

  def find_or_create_organization_on_hubee(authorization_request)
    hubee_api_client.find_organization(authorization_request.organization)
  rescue HubEEAPIClient::NotFound
    hubee_api_client.create_organization(authorization_request.organization, authorization_request.demandeur.email)
  end

  def create_subscription_on_hubee(authorization_request, hubee_organization)
    hubee_subscription_payload = hubee_api_client.create_subscription(authorization_request, hubee_organization, process_code)

    authorization_request.extra_infos['hubee_subscription_id'] = hubee_subscription_payload['id']
    authorization_request.save!
  rescue HubEEAPIClient::AlreadyExists
    # do nothing
  end

  def build_hubee_organization_id(hubee_organization_payload)
    "SI-#{hubee_organization_payload['companyRegister']}-#{hubee_organization_payload['branchCode']}"
  end

  def process_code
    'FormulaireQF'
  end

  def hubee_api_client
    @hubee_api_client ||= HubEEAPIClient.new
  end
end
