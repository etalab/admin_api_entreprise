require 'rails_helper'

RSpec.describe 'token renew page', type: :feature do
  let(:user) { create(:user, :with_token) }
  let(:token) { create(:token, user:) }

  before do
    login_as(user)
    visit token_renew_path(token)
  end

  it 'displays tokens intitules' do
    expect(page).to have_link(href: token.renewal_url)
  end
end
