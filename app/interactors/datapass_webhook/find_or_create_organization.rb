class DatapassWebhook::FindOrCreateOrganization < ApplicationInteractor
  def call
    context.organization = find_or_create_organization
    refresh_organization_data
  end

  private

  def find_or_create_organization
    Organization.find_or_create_by(siret: context.authorization_request.siret)
  end

  def refresh_organization_data
    UpdateOrganizationINSEEPayloadJob.perform_later(context.organization.id)
  end
end
