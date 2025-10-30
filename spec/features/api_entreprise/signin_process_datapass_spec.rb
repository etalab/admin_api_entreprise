require 'rails_helper'

RSpec.describe 'the signin process', app: :api_entreprise do
  it_behaves_like 'a datapass signin process',
    oauth_provider_key: :proconnect_api_entreprise
end
