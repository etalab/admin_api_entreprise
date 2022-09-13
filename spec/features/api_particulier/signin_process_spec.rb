require 'rails_helper'

RSpec.describe 'the signin process', type: :feature, app: :api_particulier do
  subject do
    visit '/compte'

    click_on 'login_header'
  end

  context 'when API Gouv authentication is successful' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:api_gouv] = OmniAuth::AuthHash.new({
        info: {
          email: user.email,
          sub: user.oauth_api_gouv_id || unknown_api_gouv_id
        }
      })
    end

    after { OmniAuth.config.test_mode = false }

    context 'when the user does not exist' do
      let!(:user) { build(:user) }

      it 'redirects to the login page' do
        subject

        expect(page).to have_current_path(api_particulier_login_path, ignore_query: true)
      end
    end

    context 'when the user exists' do
      let!(:user) { create(:user) }

      it 'redirects to the user profile' do
        subject

        expect(page).to have_current_path(api_particulier_user_profile_path, ignore_query: true)
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

      expect(page).to have_current_path(api_particulier_login_path, ignore_query: true)
    end

    it_behaves_like 'display alert', :error
  end
end
