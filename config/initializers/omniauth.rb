require 'omni_auth/strategies/api_gouv_abstract'
require 'omni_auth/strategies/api_gouv_entreprise'
require 'omni_auth/strategies/api_gouv_particulier'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :api_gouv_particulier, Rails.configuration.oauth_api_gouv_client_id_particulier, Rails.application.credentials.oauth_api_gouv_client_secret_particulier
  provider :api_gouv_entreprise, Rails.configuration.oauth_api_gouv_client_id_entreprise, Rails.application.credentials.oauth_api_gouv_client_secret_entreprise
end

OmniAuth.config.logger = Rails.logger

OmniAuth.config.on_failure = Proc.new do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end
