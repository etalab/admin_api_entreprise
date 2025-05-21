require 'rails_helper'

RSpec.describe 'the signin process', app: :api_entreprise do
  it_behaves_like 'a datapass signin process',
    oauth_provider_key: :api_gouv_entreprise
end
