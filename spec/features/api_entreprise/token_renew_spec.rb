require 'rails_helper'

RSpec.describe 'token renew page', app: :api_entreprise do
  let(:user) { token.users.first }
  let(:token) { create(:token) }

  before do
    login_as(user)

    visit token_renew_path(token)
  end

  it 'displays tokens datapass renew link' do
    expect(page).to have_link(href: datapass_renewal_url(token.authorization_request))
  end

  context 'with another user' do
    let(:user) { create(:user) }

    it 'redirects to account main page' do
      expect(page).to have_current_path(authorization_requests_path, ignore_query: true)
    end
  end
end
