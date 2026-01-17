Doorkeeper.configure do
  orm :active_record

  base_controller 'ApplicationController'

  grant_flows %w[authorization_code refresh_token]
  use_refresh_token

  default_scopes :public
  optional_scopes :public

  access_token_expires_in 1.hour
  authorization_code_expires_in 10.minutes

  resource_owner_authenticator do
    if current_user
      current_user
    else
      session[:user_return_to] = request.fullpath
      redirect_to '/oauth/login'
    end
  end

  admin_authenticator do
    current_user&.admin? || redirect_to(login_path)
  end

  force_ssl_in_redirect_uri false

  skip_authorization do
    false
  end
end

# Copy token selections from authorization codes and refresh tokens onto the issued access token.
module DoorkeeperAuthorizationSelection
  private

  def authorize_response
    @authorize_response ||= super.tap do |response|
      attach_token_selection(response)
    end
  end

  def attach_token_selection(response)
    token = response&.token
    return unless token.is_a?(Doorkeeper::AccessToken)

    selection = selection_from_request_params
    return if selection.blank?

    token.update(token_ids: selection)
  end

  def selection_from_request_params
    case params[:grant_type]
    when 'authorization_code'
      Doorkeeper::AccessGrant.find_by(token: params[:code])&.token_ids
    when 'refresh_token'
      Doorkeeper::AccessToken.by_refresh_token(params[:refresh_token])&.token_ids
    end
  end
end

module DoorkeeperApiTokensPayload
  def api_tokens_payload
    Token.where(id: Array(token_ids)).includes(:authorization_request).map do |token|
      {
        id: token.id,
        authorization_request_id: token.authorization_request_model_id,
        intitule: token.authorization_request&.intitule,
        siret: token.authorization_request&.siret,
        scopes: token.scopes,
        expires_at: token.exp,
        token: token.rehash
      }
    end
  end
end

Rails.application.config.to_prepare do
  Doorkeeper::TokensController.prepend(DoorkeeperAuthorizationSelection)
  Doorkeeper::AccessToken.include(DoorkeeperApiTokensPayload)
end
