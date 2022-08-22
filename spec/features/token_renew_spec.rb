require 'rails_helper'

RSpec.describe 'token renew page', type: :feature do
  let(:user) { create(:user, :with_token) }
  let(:token) { create(:token, user:) }

  before do
    login_as(user)
    visit token_renew_path(token)
  end

  it 'displays tokens datapass renew link' do
    expect(page).to have_link(href: datapass_renewal_url(token.authorization_request))
  end
end
