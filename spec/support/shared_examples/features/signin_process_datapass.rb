require 'rails_helper'

RSpec.shared_examples 'a datapass signin process' do |options = {}|
  subject do
    visit send(login_path_helper)
    click_button 'login_pro_connect'
  end

  let(:oauth_provider_key) { options[:oauth_provider_key] }
  let(:login_path_helper) { options[:login_path_helper] || :login_path }
  let(:authorization_requests_path_helper) { options[:authorization_requests_path_helper] || :authorization_requests_path }

  before do
    stub_request(:get, 'https://fca.integ01.dev-agentconnect.fr/api/v2/.well-known/openid-configuration')
  end

  context 'when API Gouv authentication is successful' do
    before do
      OmniAuth.config.test_mode = true

      OmniAuth.config.mock_auth[oauth_provider_key] = OmniAuth::AuthHash.new({
        info: OmniAuth::AuthHash::InfoHash.new(
          email: user.email,
          last_name: user.last_name,
          first_name: user.first_name,
          uid: user.oauth_api_gouv_id || unknown_api_gouv_id
        )
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

          expect(page).to have_current_path(send(authorization_requests_path_helper), ignore_query: true)
        end
      end

      context 'when the user exists' do
        let!(:user) { create(:user) }

        it 'redirects to the user profile' do
          subject

          expect(page).to have_current_path(send(authorization_requests_path_helper), ignore_query: true)
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

          expect(page).to have_current_path(send(authorization_requests_path_helper), ignore_query: true)
        end
      end

      context 'when the user signs in the second time (and more)' do
        let!(:user) { create(:user) }

        it 'redirects to the user profile' do
          subject

          expect(page).to have_current_path(send(authorization_requests_path_helper), ignore_query: true)
        end
      end
    end
  end

  context 'when API Gouv authentication fails' do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[oauth_provider_key] = :invalid_credentials
    end

    after { OmniAuth.config.test_mode = false }

    it 'redirects to the login page' do
      subject

      expect(page).to have_current_path(send(login_path_helper), ignore_query: true)
    end

    it_behaves_like 'display alert', :error
  end
end
