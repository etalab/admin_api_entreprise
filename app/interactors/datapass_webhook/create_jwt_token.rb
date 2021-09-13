class DatapassWebhook::CreateJwtToken < ApplicationInteractor
  def call
    return if context.event != 'validate_application'
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
    authorization_request.create_jwt_api_entreprise(
      JwtApiEntreprise.default_create_params.merge(
        subject: authorization_request.intitule,
        authorization_request_id: authorization_request.external_id,
      )
    )
  end

  def affect_roles(token)
    token.roles = Role.where(code: roles)
  end

  def token_already_exists?
    context.authorization_request.jwt_api_entreprise.present?
  end

  def roles
    context.data['pass']['scopes'].map do |code, bool|
      code if bool
    end.compact
  end

  def authorization_request
    context.authorization_request
  end
end
