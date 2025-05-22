class UpdateOrganizationINSEEPayloadJob < ApplicationJob
  attr_reader :organization

  retry_on Faraday::ServerError, wait: :polynomially_longer, attempts: Float::INFINITY
  retry_on Faraday::ConnectionFailed, wait: :polynomially_longer, attempts: Float::INFINITY

  def perform(organization_id)
    @organization = Organization.find(organization_id)

    return if last_update_within_24h?

    update_organization_insee_payload
  # rubocop:disable Lint/SuppressedException
  rescue ActiveRecord::RecordNotFound
  end
  # rubocop:enable Lint/SuppressedException

  private

  def last_update_within_24h?
    organization.last_insee_payload_updated_at.present? &&
      organization.last_insee_payload_updated_at > 24.hours.ago
  end

  def update_organization_insee_payload
    organization.update(
      insee_payload:,
      last_insee_payload_updated_at: DateTime.current
    )
  end

  def insee_payload
    INSEESireneAPIClient.new.etablissement(siret: organization.siret)
  end
end
