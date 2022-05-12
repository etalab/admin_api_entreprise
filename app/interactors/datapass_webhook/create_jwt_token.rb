class DatapassWebhook::CreateJwtToken < ApplicationInteractor
  def call
    return if %w[validate_application validate].exclude?(context.event)
    return if token_already_exists?

    token = create_jwt_token

    if token.persisted?
      affect_roles(token)
      context.token_id = token.id
    else
      context.fail!(message: 'Fail to create token')
    end
  end

  private

  def create_jwt_token
    authorization_request.create_token(
      Token.default_create_params.merge(
        authorization_request_id: authorization_request.external_id
      )
    )
  end

  def affect_roles(token)
    token.roles = Role.where(code: roles)
  end

  def token_already_exists?
    context.authorization_request.token.present?
  end

  def roles
    context.data['pass']['scopes'].map { |code, bool|
      code if bool
    }.compact
  end

  def authorization_request
    context.authorization_request
  end
end
