require "net/http"

module OAuthApiGouv::Tasks
  class RetrieveAccessToken < Trailblazer::Operation
    step :request_access_tokens
    step :valid_response?
    fail :log_error
    fail :invalid_authorization_code?, Output(:success) => End(:invalid_authorization_code)
    step :extract_tokens_from_response
    step :fetch_jwks_for_id_token_verification
    step :verify_id_token
    step :extract_oauth_api_gouv_user_id


    def request_access_tokens(ctx, authorization_code:, **)
      uri = URI("#{Rails.configuration.oauth_api_gouv_baseurl}/oauth/token")
      res = Net::HTTP.post_form(uri, {
        grant_type: 'authorization_code',
        code: authorization_code,
        client_id: Rails.configuration.oauth_api_gouv_client_id,
        client_secret: Rails.application.secrets.oauth_api_gouv_client_secret,
        redirect_uri: Rails.configuration.oauth_api_gouv_redirect_uri
      })
      ctx[:oauth_response] = res
    end

    def valid_response?(ctx, oauth_response:, **)
      oauth_response.code == '200'
    end

    def extract_tokens_from_response(ctx, oauth_response:, **)
      body = JSON.parse(oauth_response.body, symbolize_names: true)
      ctx[:access_token] = body[:access_token]
      ctx[:id_token] = body[:id_token]
    end

    def fetch_jwks_for_id_token_verification(ctx, **)
      jwks_raw = Net::HTTP.get(URI("#{Rails.configuration.oauth_api_gouv_baseurl}/jwks"))
      ctx[:jwks] = JSON.parse(jwks_raw, symbolize_names: true)[:keys]
    end

    def verify_id_token(ctx, id_token:, jwks:, **)
      ctx[:id_token_payload] = AccessToken.decode_oauth_api_gouv_id_token(id_token, jwks)
    end

    def extract_oauth_api_gouv_user_id(ctx, id_token_payload:, **)
      ctx[:oauth_api_gouv_user_id] = id_token_payload[:sub]
    end

    def log_error(ctx, oauth_response:, **)
      Rails.logger.error("OAuth API Gouv call failed: status #{oauth_response.code}, description #{oauth_response.body}")
    end

    def invalid_authorization_code?(ctx, oauth_response:, **)
      body = JSON.parse(oauth_response.body)
      oauth_response.code == '400' && body["error"] = 'invalid_grant'
    end
  end
end
