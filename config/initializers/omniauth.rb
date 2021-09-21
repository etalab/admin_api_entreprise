Rails.application.config.middleware.use OmniAuth::Builder do
  provider :api_gouv, Rails.configuration.oauth_api_gouv_client_id, Rails.application.credentials.oauth_api_gouv_client_secret
end

OmniAuth.config.logger = Rails.logger

OmniAuth.config.on_failure = Proc.new do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end
