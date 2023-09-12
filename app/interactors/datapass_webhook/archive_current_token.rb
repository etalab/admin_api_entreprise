class DatapassWebhook::ArchiveCurrentToken < ApplicationInteractor
  def call
    return unless context.event == 'archive'
    return unless token_already_exists?

    context.authorization_request.archive!
  end

  private

  def token_already_exists?
    context.authorization_request.token.present?
  end
end
