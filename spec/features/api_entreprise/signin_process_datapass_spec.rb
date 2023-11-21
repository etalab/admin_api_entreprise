require 'rails_helper'

RSpec.describe 'the signin process', app: :api_entreprise do
  subject do
    visit login_path
    click_button 'login_mon_compte_pro'
  end

  context 'when API Gouv authentication is successful' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:api_gouv_entreprise] = OmniAuth::AuthHash.new({
        info: {
          email: user.email,
          family_name: user.last_name,
          given_name: user.first_name,
          sub: user.oauth_api_gouv_id || unknown_api_gouv_id
        }
      })
    end

    after { OmniAuth.config.test_mode = false }

    describe 'simple login' do
      context 'when the user is unknown' do
        let!(:user) { build(:user) }

        it 'creates a user with valid attributes and redirects to his profile' do
          expect {
            subject
          }.to change(User, :count).by(1)

          latest_user = User.last

          %w[email first_name last_name].each do |attr|
            expect(latest_user.send(attr)).to eq(user.send(attr))
          end

          expect(page).to have_current_path(authorization_requests_path, ignore_query: true)
        end
      end

      context 'when the user exists' do
        let!(:user) { create(:user) }

        it 'redirects to the user profile' do
          subject

          expect(page).to have_current_path(authorization_requests_path, ignore_query: true)
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

        it 'sends an email to DataPass to update the authorization request owner' do
          expect { subject }
            .to have_enqueued_mail(APIEntreprise::UserMailer, :notify_datapass_for_data_reconciliation)
            .with(user)
        end

        it 'redirects to the user profile' do
          subject

          expect(page).to have_current_path(authorization_requests_path, ignore_query: true)
        end
      end

      context 'when the user signs in the second time (and more)' do
        let!(:user) { create(:user) }

        it 'does not send any email to DataPass' do
          expect { subject }
            .not_to have_enqueued_mail(APIEntreprise::UserMailer, :notify_datapass_for_data_reconciliation)
        end

        it 'redirects to the user profile' do
          subject

          expect(page).to have_current_path(authorization_requests_path, ignore_query: true)
        end
      end
    end
  end

  context 'when API Gouv authentication fails' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:api_gouv_entreprise] = :invalid_credentials
    end

    after { OmniAuth.config.test_mode = false }

    it 'redirects to the login page' do
      subject

      expect(page).to have_current_path(login_path, ignore_query: true)
    end

    it_behaves_like 'display alert', :error
  end
end
