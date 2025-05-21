require 'rails_helper'

RSpec.describe 'create a token magic link', app: :api_particulier do
  it_behaves_like 'a token magic link creation feature',
    mailer_class: APIParticulier::TokenMailer,
    login_path_helper: :api_particulier_login_path,
    api: 'particulier'
end
