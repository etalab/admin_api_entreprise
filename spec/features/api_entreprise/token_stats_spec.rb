require 'rails_helper'

RSpec.describe 'Stats page for a token', app: :api_entreprise do
  let(:user) { token.users.first }
  let(:token) { create(:token) }

  before do
    login_as(user)

    visit token_stats_path(token)
  end

  it 'displays the token details (happy path)' do
    expect(page).to have_content(token.intitule)
    expect(page).to have_content(token.id)
  end

  context 'with another user' do
    let(:user) { create(:user) }

    it 'redirects to account homepage' do
      expect(page).to have_current_path(authorization_requests_path, ignore_query: true)
    end
  end
end
