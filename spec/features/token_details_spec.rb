require 'rails_helper'

RSpec.describe 'token details page', type: :feature do
  let(:user) { create(:user, :with_jwt) }
  let(:token) { create(:token, user:) }

  before do
    login_as(user)
    visit token_path(token)
  end

  it 'displays tokens intitules' do
    expect(page).to have_content(token.intitule)
  end

  it 'displays tokens creation date' do
    expect(page).to have_content(friendly_format_from_timestamp(token.iat))
  end

  it 'displays tokens expiration date' do
    expect(page).to have_content(friendly_format_from_timestamp(token.exp))
  end

  it 'has a button to copy active tokens hash to clipboard' do
    expect(page).to have_css("##{dom_id(token, :copy_button)}")
  end

  it 'displays tokens access scopes' do
    token = create(:token, :with_scopes, user:)
    scopes = token.scopes.pluck(:code)
    visit token_path(token)

    expect(page).to have_content(*scopes)
  end

  it 'has a button to create a magic link' do
    expect(page).to have_button(dom_id(token, :modal_button))
  end

  it 'has a link to access token stats' do
    expect(page).to have_link(href: token_stats_path(token))
  end

  it 'has a link to the token contacts' do
    expect(page).to have_link(href: token_contacts_path(token))
  end

  context 'when the token has an authorization request' do
    it 'has a link for token renewal' do
      expect(page).to have_link(dom_id(token, :renew))
    end

    it 'has a link to authorization request' do
      expect(page).to have_link(href: token.authorization_request_url)
    end
  end

  context 'when connected as a simple user' do
    it 'has no button to archive tokens' do
      expect(page).not_to have_button(dom_id(token, :archive_button))
    end

    it 'has no button to blacklist tokens' do
      expect(page).not_to have_button(dom_id(token, :blacklist_button))
    end
  end
end
