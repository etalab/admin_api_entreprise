require 'rails_helper'

RSpec.describe 'User JWT listing', type: :feature do
  subject(:token_index) { visit user_tokens_path }

  let(:user) { create(:user, :with_token) }

  context 'when the user is not authenticated' do
    it 'redirects to the login' do
      token_index

      expect(page).to have_current_path(login_path, ignore_query: true)
    end
  end

  context 'when the user is authenticated' do
    before { login_as(user) }

    let(:token) { user.token.take }

    it_behaves_like 'it displays user owned token'

    it 'does not display archived tokens' do
      archived_token = create(:token, :archived, user:)
      token_index

      expect(page).not_to have_css("input[value='#{archived_token.rehash}']")
    end

    it 'does not display blacklisted tokens' do
      blacklisted_token = create(:token, :blacklisted, user:)
      token_index

      expect(page).not_to have_css("input[value='#{blacklisted_token.rehash}']")
    end

    it 'does not display expired tokens' do
      expired_token = create(:token, exp: 1.day.ago, user:)
      token_index

      expect(page).not_to have_css("input[value='#{expired_token.rehash}']")
    end

    it 'has no button to archive tokens' do
      token_index

      expect(page).not_to have_button(dom_id(token, :archive_button))
    end

    it 'has no button to blacklist tokens' do
      token_index

      expect(page).not_to have_button(dom_id(token, :blacklist_button))
    end
  end
end
