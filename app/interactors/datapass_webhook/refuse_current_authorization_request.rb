class DatapassWebhook::RefuseCurrentAuthorizationRequest < ApplicationInteractor
  def call
    return unless context.event == 'refuse'
    return unless token_already_exists?
    return unless prolong_token_wizard_updates_requested?

    context.authorization_request.token.last_prolong_token_wizard.update!(status: 'updates_refused')
  end

  private

  def token_already_exists?
    context.authorization_request.token.present?
  end

  def prolong_token_wizard_updates_requested?
    context.authorization_request.token.last_prolong_token_wizard.presence && (
      context.authorization_request.token.last_prolong_token_wizard.requires_update? ||
      context.authorization_request.token.last_prolong_token_wizard.updates_requested?
    )
  end
end
