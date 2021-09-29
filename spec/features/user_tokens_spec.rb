require 'rails_helper'

RSpec.describe 'User JWT listing', type: :feature do
  let(:user) { create(:user, :with_jwt) }
  subject(:jwt_index) { visit user_tokens_path }

  context 'when the user is not authenticated' do
    it 'redirects to the login' do
      jwt_index

      expect(page.current_path).to eq(login_path)
    end
  end

  context 'when the user is authenticated' do
    before { log_as(user) }

    it 'lists the user\'s active tokens' do
      jwt_index

      user.jwt_api_entreprise.each do |jwt|
        expect(page).to have_content(jwt.rehash)
      end
    end

    it 'does not list other users tokens' do
      another_user = create(:user, :with_jwt)
      jwt_index

      another_user.jwt_api_entreprise.each do |jwt|
        expect(page).to_not have_content(jwt.rehash)
      end
    end

    it 'does not display archived tokens' do
      archived_jwt = create(:jwt_api_entreprise, :archived, user: user)
      jwt_index

      expect(page).to_not have_content(archived_jwt.rehash)
    end

    it 'does not display blacklisted tokens' do
      blacklisted_jwt = create(:jwt_api_entreprise, :blacklisted, user: user)
      jwt_index

      expect(page).to_not have_content(blacklisted_jwt.rehash)
    end

    it 'does not display expired tokens' do
      expired_jwt = create(:jwt_api_entreprise, :expired)
      jwt_index

      expect(page).to_not have_content(expired_jwt.rehash)
    end
  end
end
