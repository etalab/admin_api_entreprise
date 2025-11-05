require 'rails_helper'

RSpec.describe 'create a token magic link', app: :api_entreprise do
  before do
    stub_hyperping_request_operational('entreprise')
  end

  it_behaves_like 'a token magic link creation feature',
    mailer_class: APIEntreprise::TokenMailer
end
