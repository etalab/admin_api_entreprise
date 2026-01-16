class OAuth::MeController < Doorkeeper::ApplicationController
  before_action :doorkeeper_authorize!

  def show
    token = doorkeeper_token
    render json: {
      oauth_token: {
        id: token.id,
        scopes: token.scopes.to_a,
        expires_in: token.expires_in,
        created_at: token.created_at
      },
      api_tokens: token.api_tokens_payload
    }
  end
end
