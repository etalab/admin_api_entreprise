require 'rails_helper'

RSpec.describe 'token details page', type: :feature do
  let(:user) { create(:user, :with_jwt) }
  let(:token) { create(:jwt_api_entreprise, user: user) }

  before do
    login_as(user)
    visit token_path(token)
  end

  it 'displays tokens subject' do
    expect(page).to have_content(token.displayed_subject)
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

  it 'displays tokens access roles' do
    token = create(:jwt_api_entreprise, :with_roles, user: user)
    roles = token.roles.pluck(:code)
    visit token_path(token)

    expect(page).to have_content(*roles)
  end

  it 'has a button to create a magic link' do
    expect(page).to have_button(dom_id(token, :modal_button))
  end

  it 'has a link to access token stats' do
    expect(page).to have_link(href: token_stats_path(token))
  end

  context 'when the token has an authorization request' do
    it 'has a link for token renewal' do
      expect(page).to have_button(dom_id(token, :renew))
    end

    it 'has a link to authorization request' do
      expect(page).to have_link(href: token.authorization_request_url)
    end
  end

  context 'when the token has no authorization request' do
    let(:user) { create(:user, :admin) }
    let(:token) { create(:jwt_api_entreprise, :without_authorization_request_id) }

    context 'when the token has no authorization request' do
      it 'works' do
        expect { visit token_path(token) }.not_to raise_error
      end
    end
  end

  context 'when connected as a simple user' do
    it 'has no button to archive tokens' do
      expect(page).to_not have_button(dom_id(token, :archive_button))
    end

    it 'has no button to blacklist tokens' do
      expect(page).to_not have_button(dom_id(token, :blacklist_button))
    end
  end

  context 'when connected as an admin' do
    let(:user) { create(:user, :admin) }

    it 'has button to archive tokens' do
      expect(page).to have_button(dom_id(token, :archive_button))
    end

    it 'has button to blacklist tokens' do
      expect(page).to have_button(dom_id(token, :blacklist_button))
    end
  end
end
