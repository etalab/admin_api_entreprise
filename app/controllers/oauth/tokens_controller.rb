class OAuth::TokensController < Doorkeeper::TokensController
  def create
    headers.merge!(authorize_response.headers)

    body = authorize_response.body
    token = authorize_response.try(:token)
    if token.respond_to?(:api_tokens_payload)
      token.reload
      body = body.merge('api_tokens' => token.api_tokens_payload)
    end

    render json: body, status: authorize_response.status
  end
end
