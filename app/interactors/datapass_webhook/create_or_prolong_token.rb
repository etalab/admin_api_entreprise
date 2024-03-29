class DatapassWebhook::CreateOrProlongToken < ApplicationInteractor
  def call
    return if %w[approve validate].exclude?(context.event)

    token = create_or_prolong_token

    if token.persisted?
      affect_scopes(token)
      context.token_id = token.id
    else
      context.fail!(message: 'Fail to create token')
    end
  end

  private

  def create_or_prolong_token
    if token_already_exists?
      prolong_token!
      context.authorization_request.token
    else
      create_token
    end
  end

  def prolong_token!
    if context.authorization_request.token.last_prolong_token_wizard.present?
      context.authorization_request.token.last_prolong_token_wizard.prolong!
    else
      context.authorization_request.token.prolong!
    end
  end

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
    valid_scopes = extract_checked_scopes
    valid_scopes << 'open_data' if valid_scopes.any? { |scope| scope.start_with?('open_data_') }
    valid_scopes.reject! { |scope| scope.start_with?('open_data_') }
    valid_scopes.compact.uniq
  end

  def extract_checked_scopes
    context.data['pass']['scopes'].map do |code, bool|
      code if bool
    end
  end

  def authorization_request
    context.authorization_request
  end
end
