require 'rails_helper'

RSpec.describe 'user profile page', app: :api_entreprise do
  it_behaves_like 'a user profile feature',
    user_profile_path_helper: :user_profile_path
end
