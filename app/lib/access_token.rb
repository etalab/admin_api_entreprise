# TODO: rename to APIEntrepriseAccessToken
class AccessToken
  class << self
    HASH_SECRET = Rails.application.credentials.jwt_hash_secret
    HASH_ALGO = Rails.application.credentials.jwt_hash_algo

    def create(payload)
      JWT.encode payload, HASH_SECRET, HASH_ALGO
    end

    def decode(token)
      payload = JWT.decode token, HASH_SECRET, true,
        verify_iat: true,
        algorithm: HASH_ALGO
      payload.map(&:deep_symbolize_keys!)
      payload.first
    end

    def decode_oauth_api_gouv_id_token(token, jwks)
      payload = JWT.decode(token, nil, true, {
        algorithms: ['RS256'],
        aud: Rails.configuration.oauth_api_gouv_client_id,
        verify_aud: true,
        iss: Rails.configuration.oauth_api_gouv_issuer,
        verify_iss: true,
        jwks: { keys: jwks }
      })
      payload.map(&:deep_symbolize_keys!)
      payload.first
    rescue JWT::VerificationError,
           JWT::InvalidAudError,
           JWT::InvalidIssuerError,
           JWT::ExpiredSignature => e

      Rails.logger.error('ID Token verification error: ' + e.message)
      nil
    end
  end
end
