class DatapassWebhook::ArchiveCurrentToken < ApplicationInteractor
  def call
    return if %w[archive].exclude?(context.event)
    return unless token_already_exists?

    authorization_request = context.authorization_request
    token = context.authorization_request.token
    token.update!(archived: true)
    authorization_request.update!(status: 'archived')
  end

  private

  def token_already_exists?
    context.authorization_request.token.present?
  end
end
