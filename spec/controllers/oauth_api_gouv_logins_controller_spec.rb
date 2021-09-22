require 'rails_helper'

RSpec.describe OAuthApiGouvLoginsController, type: :controller do
  describe '#create' do
    subject { get :create }

    let(:login_session) { session[:current_user_id] }

    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:api_gouv] = OmniAuth::AuthHash.new({
        info: {
          email: user.email,
          sub: user.oauth_api_gouv_id,
        }
      })
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:api_gouv]
    end

    after { OmniAuth.config.test_mode = false }

    context 'when the user is not known from API Entreprise' do
      let!(:user) { build(:user) }

      it 'does not log in the user' do
        subject

        expect(login_session).to be_blank
      end
    end

    context 'when the user is an admin' do
      let!(:user) { create(:user, :admin) }

      it 'persists login with a cookie' do
        subject

        expect(login_session).to eq(user.id)
      end
    end

    context 'when the user is not an admin' do
      let!(:user) { create(:user) }

      it 'persists login with a cookie' do
        subject

        expect(login_session).to eq(user.id)
      end
    end
  end
end
