JWTF.configure do |config|
  config.algorithm = Rails.application.secrets.jwt_hash_algo
  config.secret = Rails.application.secrets.jwt_hash_secret

  config.token_payload do |resource_owner_id:, **|
    { uid: resource_owner_id }
  end
end
