require 'vcr'
require 'webmock/rspec'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_localhost = true

  c.filter_sensitive_data('<OAUTH_API_GOUV_CLIENT_SECRET>') { Rails.application.credentials.oauth_api_gouv_client_secret.to_s }
  c.filter_sensitive_data('<ELASTIC_SERVER_DOMAIN>') { Rails.application.credentials.elastic_server_domain.to_s }
end
