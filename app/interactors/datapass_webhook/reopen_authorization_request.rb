class DatapassWebhook::ReopenAuthorizationRequest < ApplicationInteractor
  def call
    return unless context.event == 'reopen'
    return unless token_already_exists?
    return unless prolong_token_wizard_requires_update?

    context.authorization_request.token.last_prolong_token_wizard.update!(status: 'updates_requested')
  end

  private

  def token_already_exists?
    context.authorization_request.token.present?
  end

  def prolong_token_wizard_requires_update?
    context.authorization_request.token.last_prolong_token_wizard.presence && context.authorization_request.token.last_prolong_token_wizard.requires_update?
  end
end
