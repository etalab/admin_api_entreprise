class AccessToken
  class << self
    HASH_SECRET = Rails.application.secrets.jwt_hash_secret
    HASH_ALGO = Rails.application.secrets.jwt_hash_algo

    def create(payload)
      JWT.encode payload, HASH_SECRET, HASH_ALGO
    end

    def decode(token)
      payload = JWT.decode token, HASH_SECRET, true, { verify_iat: true, algorithm: HASH_ALGO }
      payload.map(&:deep_symbolize_keys!)
    end

    def get_scope(token)
      payload = decode token
      scope_a = payload.select { |e| e.has_key? :scope }
      scope_a.first[:scope]
    end
  end
end
