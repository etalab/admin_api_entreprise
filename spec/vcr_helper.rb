require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into(:webmock)
  c.configure_rspec_metadata!

  c.filter_sensitive_data('<OAUTH_API_GOUV_CLIENT_SECRET>' ) { "#{Rails.application.credentials.oauth_api_gouv_client_secret}" }
end
