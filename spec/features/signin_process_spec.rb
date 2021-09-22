require 'rails_helper'

RSpec.describe 'the signin process', type: :feature do
  subject do
    visit login_path
    click_on 'login'
  end

  context 'when API Gouv authentication is successful' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:api_gouv] = OmniAuth::AuthHash.new({
        info: {
          email: user.email,
          sub: user.oauth_api_gouv_id,
        }
      })
    end

    after { OmniAuth.config.test_mode = false }

    context 'when the user is unknown from API Entreprise' do
      let!(:user) { build(:user) }

      it 'redirects to the login page' do
        subject

        expect(page.current_path).to eq('/login')
      end
    end

    context 'when the user is an admin' do
      let!(:user) { create(:user, :admin) }

      it 'redirects to the users index page' do
        subject

        expect(page.current_path).to eq('/users')
      end
    end

    context 'when the user is not an admin' do
      let!(:user) { create(:user) }

      it 'redirects to the user detail page' do
        subject

        expect(page.current_path).to eq("/users/#{user.id}")
      end
    end
  end

  context 'when API Gouv authentication fails' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:api_gouv] = :invalid_credentials
    end

    after { OmniAuth.config.test_mode = false }

    it 'redirects to the login page' do
      subject

      expect(page.current_path).to eq('/login')
    end
  end
end
