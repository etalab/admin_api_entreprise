require 'rails_helper'

RSpec.describe 'the signin process', app: :api_particulier do
  subject do
    visit login_path
    click_on 'login_mon_compte_pro'
  end

  context 'when API Gouv authentication is successful' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:api_gouv_particulier] = OmniAuth::AuthHash.new({
        info: {
          email: user.email,
          sub: user.oauth_api_gouv_id || unknown_api_gouv_id
        }
      })
    end

    after { OmniAuth.config.test_mode = false }

    describe 'simple login' do
      context 'when the user is unknown' do
        let!(:user) { build(:user) }

        it 'redirects to the login page and print wrong email' do
          subject

          expect(page).to have_current_path(api_particulier_login_path, ignore_query: true)
          expect(page).to have_content(user.email)
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

    describe 'new user who received tokens by account transfer' do
      context 'when the user signs in for the first time' do
        let!(:user) { create(:user, :new_token_owner) }
        let(:unknown_api_gouv_id) { '1234' }

        it 'updates the user OAuth API Gouv ID' do
          subject
          user.reload

          expect(user.oauth_api_gouv_id).to eq(unknown_api_gouv_id)
        end

        it 'redirects to the user profile' do
          subject

          expect(page).to have_current_path(user_profile_path, ignore_query: true)
        end
      end

      context 'when the user signs in the second time (and more)' do
        let!(:user) { create(:user) }

        it 'does not send any email to DataPass' do
          expect { subject }
            .not_to have_enqueued_mail(UserMailer, :notify_datapass_for_data_reconciliation)
        end

        it 'redirects to the user profile' do
          subject

          expect(page).to have_current_path(user_profile_path, ignore_query: true)
        end
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

    it_behaves_like 'display alert', :info
  end
end
