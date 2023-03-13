class DatapassWebhook::ArchiveCurrentToken < ApplicationInteractor
  def call
    return if %w[archive].exclude?(context.event)
    return unless token_already_exists?

    token = context.authorization_request.token
    token.update!(archived: true)
  end

  private

  def token_already_exists?
    context.authorization_request.token.present?
  end
end
