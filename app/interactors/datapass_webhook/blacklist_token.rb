class DatapassWebhook::BlacklistToken < ApplicationInteractor
  def call
    return if %w[revoke].exclude?(context.event)
    return if token.blank?

    token.update!(
      blacklisted: true
    )
  end

  private

  def token
    context.authorization_request.token
  end
end
