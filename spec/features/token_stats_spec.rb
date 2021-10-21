require 'rails_helper'

RSpec.describe 'stats page for a token', type: :feature do
  let(:user) { create(:user, :with_jwt) }
  let(:token) { user.jwt_api_entreprise.take }

  subject { visit token_stats_path(token) }

  before { login_as(user) }

  it 'has a link back to the list of tokens' do
    subject

    expect(page).to have_link(href: user_tokens_path)
  end

  it 'displays the token use case' do
    subject

    expect(page).to have_content(token.displayed_subject)
  end

  it 'displays the token internal ID' do
    subject

    expect(page).to have_content(token.id)
  end

  describe 'calls rate' do
    it 'displays the rate of requests made with the token' do
      subject

      expect(page).to have_css('#calls_rate')
    end
  end

  describe 'number of calls' do
    it 'displays the number of calls' do
      subject

      expect(page).to have_css('#calls_number')
    end
  end

  describe 'last calls details' do
    it 'displays the details of the last few calls' do
      subject

      expect(page).to have_css('#calls_detail')
    end
  end
end
