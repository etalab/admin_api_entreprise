require 'rails_helper'

RSpec.describe 'the signin process', app: :api_particulier do
  it_behaves_like 'a datapass signin process',
    oauth_provider_key: :api_gouv_particulier,
    login_path_helper: :api_particulier_login_path,
    authorization_requests_path_helper: :api_particulier_authorization_requests_path
end
