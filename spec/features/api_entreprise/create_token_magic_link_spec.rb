require 'rails_helper'

RSpec.describe 'create a token magic link', app: :api_entreprise do
  it_behaves_like 'a token magic link creation feature',
    mailer_class: APIEntreprise::TokenMailer
end
