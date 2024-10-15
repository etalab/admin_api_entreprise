class DatapassWebhook::APIParticulier::CreateHubEEOrganization < ApplicationInteractor
  delegate :authorization_request, :hubee_organization_payload, to: :context

  def call
    context.hubee_organization_payload = find_or_create_organization_on_hubee
    save_hubee_organization_id_to_authorization_request
  end

  private

  def build_hubee_organization_id
    "SI-#{hubee_organization_payload['companyRegister']}-#{hubee_organization_payload['branchCode']}"
  end

  def find_or_create_organization_on_hubee
    hubee_api_client.find_or_create_organization(authorization_request.organization, authorization_request.demandeur.email)
  end

  def hubee_api_client
    @hubee_api_client ||= HubEEAPIClient.new
  end

  def save_hubee_organization_id_to_authorization_request
    authorization_request.extra_infos['hubee_organization_id'] = build_hubee_organization_id
    authorization_request.save!
  end
end
