require 'rails_helper'

RSpec.describe 'User JWT listing', type: :feature do
  subject(:jwt_index) { visit user_tokens_path }

  let(:user) { create(:user, :with_jwt) }

  context 'when the user is not authenticated' do
    it 'redirects to the login' do
      jwt_index

      expect(page).to have_current_path(login_path, ignore_query: true)
    end
  end

  context 'when the user is authenticated' do
    before { login_as(user) }

    let(:jwt) { user.jwt_api_entreprise.take }

    it_behaves_like 'it displays user owned token'

    it 'does not display archived tokens' do
      archived_jwt = create(:jwt_api_entreprise, :archived, user: user)
      jwt_index

      expect(page).not_to have_css("input[value='#{archived_jwt.rehash}']")
    end

    it 'does not display blacklisted tokens' do
      blacklisted_jwt = create(:jwt_api_entreprise, :blacklisted, user: user)
      jwt_index

      expect(page).not_to have_css("input[value='#{blacklisted_jwt.rehash}']")
    end

    it 'has no button to archive tokens' do
      jwt_index

      expect(page).not_to have_button(dom_id(jwt, :archive_button))
    end

    it 'has no button to blacklist tokens' do
      jwt_index

      expect(page).not_to have_button(dom_id(jwt, :blacklist_button))
    end
  end
end
