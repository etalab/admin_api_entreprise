require 'vcr'
require 'webmock/rspec'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_localhost = true

  c.default_cassette_options = if ENV['regenerate_cassettes']
                                 # when regenerating cassettes it allows to add episodes with remote_storage at 'true' and THEN at 'false'
                                 { record: :new_episodes, allow_playback_repeats: true, match_requests_on: %i[method uri body headers] }
                               else
                                 # due to legacy we can't match on headers & body. But new ones will be ok
                                 { record: :none, allow_playback_repeats: true, match_requests_on: %i[method uri] }
                               end

  c.filter_sensitive_data('<OAUTH_API_GOUV_CLIENT_SECRET>') { Rails.application.credentials.oauth_api_gouv_client_secret.to_s }
  c.filter_sensitive_data('<ELASTIC_SERVER_DOMAIN>') { Rails.application.credentials.elastic_server_domain.to_s }
end
