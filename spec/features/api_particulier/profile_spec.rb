require 'rails_helper'

RSpec.describe 'API Particulier: profile spec', app: :api_particulier do
  it_behaves_like 'a user profile feature',
    user_profile_path_helper: :api_particulier_user_profile_path,
    login_path_helper: :api_particulier_login_path,
    with_token: true,
    check_user_info: false
end
