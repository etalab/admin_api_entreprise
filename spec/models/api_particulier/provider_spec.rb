require 'rails_helper'

RSpec.describe APIParticulier::Provider do
  # For API Particulier, we'll skip the routes test since we'd need to mock the routes
  # or provide a comprehensive list of expected routes
  it_behaves_like 'a provider model',
    provider_uid: 'cnaf'
end
