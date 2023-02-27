require 'rails_helper'

RSpec.describe 'Stats page for a token', app: :api_entreprise do
  subject { visit token_stats_path(token) }

  let(:user) { create(:user, :with_token) }
  let(:token) { user.tokens.take }

  before do
    login_as(user)
  end

  it 'displays the token details (happy path)' do
    subject

    expect(page).to have_content(token.intitule)
    expect(page).to have_content(token.id)
  end
end
