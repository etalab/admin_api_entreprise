require 'rails_helper'

RSpec.describe APIParticulier::AuthenticatedUsersController do
  it_behaves_like 'an authenticated users controller',
    login_path_helper: :api_particulier_login_path
end
