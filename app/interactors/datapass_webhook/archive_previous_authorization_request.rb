# frozen_string_literal: true

class DatapassWebhook::ArchivePreviousAuthorizationRequest < ApplicationInteractor
  def call
    return if %w[validate_application validate].exclude?(context.event)
    return if context.authorization_request.previous_external_id.blank?
    return if previous_authorization_request.blank?

    previous_authorization_request.archive!
  end

  private

  def previous_authorization_request
    AuthorizationRequest.find_by(external_id: context.authorization_request.previous_external_id)
  end
end
