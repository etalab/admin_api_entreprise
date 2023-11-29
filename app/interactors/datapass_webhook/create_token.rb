class DatapassWebhook::CreateToken < ApplicationInteractor
  def call
    return if %w[validate_application validate].exclude?(context.event)
    return if token_already_exists?

    token = create_token

    if token.persisted?
      affect_scopes(token)
      context.token_id = token.id
    else
      context.fail!(message: 'Fail to create token')
    end
  end

  private

  def create_token
    authorization_request.tokens.create(
      Token.default_create_params.merge(
        context.token_create_extra_params || {}
      )
    )
  end

  def affect_scopes(token)
    token.update!(scopes:)
  end

  def token_already_exists?
    context.authorization_request.token.present?
  end

  def scopes
    context.data['pass']['scopes'].map { |code, bool|
      code if bool
    }.compact
  end

  def authorization_request
    context.authorization_request
  end
end
