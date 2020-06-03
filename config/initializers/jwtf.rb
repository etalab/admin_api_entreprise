JWTF.configure do |config|
  config.algorithm = Rails.application.credentials.jwt_hash_algo
  config.secret = Rails.application.credentials.jwt_hash_secret

  config.token_payload do |resource_owner_id:, **|
    user = User.find(resource_owner_id)
    payload = { uid: resource_owner_id }
    payload[:admin] = true if resource_owner_id == Rails.application.credentials.admin_uid
    payload
  end

  config.use_iat_claim = true
  config.exp_period = { hours: 4 }
end
