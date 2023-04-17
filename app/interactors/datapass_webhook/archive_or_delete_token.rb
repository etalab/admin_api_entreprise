class DatapassWebhook::ArchiveOrDeleteToken < ApplicationInteractor
  def call
    return if %w[archive].exclude?(context.event)
    return if token.blank?

    if token.blacklisted?
      return token.update!(
        archived: true
      )
    end

    token.delete
  end

  private

  def token
    context.authorization_request.token
  end
end
