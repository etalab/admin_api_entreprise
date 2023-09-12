class DatapassWebhook::RevokeCurrentToken < ApplicationInteractor
  def call
    return unless context.event == 'revoke'
    return unless token_already_exists?

    context.authorization_request.blacklist!
  end

  private

  def token_already_exists?
    context.authorization_request.token.present?
  end
end
