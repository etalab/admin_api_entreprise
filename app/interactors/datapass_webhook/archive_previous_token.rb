# frozen_string_literal: true

class DatapassWebhook::ArchivePreviousToken < ApplicationInteractor
  def call
    return if %w(validate_application validate).exclude?(context.event)
    return if context.authorization_request.previous_external_id.blank?
    return if previous_token.blank?

    previous_token.update(
      archived: true,
    )
  end

  private

  def previous_token
    @previous_token ||= begin
      previous_authorization_request = AuthorizationRequest.find_by(external_id: context.authorization_request.previous_external_id)

      previous_authorization_request.try(:jwt_api_entreprise)
    end
  end
end
