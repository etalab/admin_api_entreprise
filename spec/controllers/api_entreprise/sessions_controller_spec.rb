require 'rails_helper'

RSpec.describe APIEntreprise::SessionsController do
  describe 'GET #create_from_oauth' do
    let(:user) { create(:user) }
    let(:valid_provider) { 'proconnect_api_entreprise' }
    let(:omniauth_auth_data) do
      OpenStruct.new(
        info: {
          'email' => user.email,
          'first_name' => 'John',
          'last_name' => 'Doe',
          'uid' => '123456'
        }
      )
    end

    before do
      allow(MonitoringService.instance).to receive(:track)
    end

    context 'with valid provider and omniauth data' do
      before do
        request.env['omniauth.auth'] = omniauth_auth_data
      end

      it 'allows the oauth callback' do
        get :create_from_oauth, params: { provider: valid_provider }

        expect(response).to redirect_to(authorization_requests_path)
      end

      it 'does not track security events' do
        get :create_from_oauth, params: { provider: valid_provider }

        expect(MonitoringService.instance).not_to have_received(:track)
      end

      it 'creates user session' do
        get :create_from_oauth, params: { provider: valid_provider }

        expect(session[:current_user_id]).to eq(user.id)
      end
    end

    context 'with valid provider but missing omniauth data' do
      before do
        request.env['omniauth.auth'] = nil
      end

      it 'redirects to login path' do
        get :create_from_oauth, params: { provider: valid_provider }

        expect(response).to redirect_to(login_path)
      end

      it 'tracks missing omniauth data' do
        get :create_from_oauth, params: { provider: valid_provider }

        expect(MonitoringService.instance).to have_received(:track).with(
          'OAuth security: Missing OmniAuth data',
          level: 'info',
          context: {
            provider: valid_provider,
            ip: request.remote_ip
          }
        )
      end

      it 'does not create user session' do
        get :create_from_oauth, params: { provider: valid_provider }

        expect(session[:current_user_id]).to be_nil
      end
    end

    describe 'provider whitelist validation' do
      before do
        request.env['omniauth.auth'] = omniauth_auth_data
      end

      it 'allows proconnect_api_entreprise' do
        get :create_from_oauth, params: { provider: 'proconnect_api_entreprise' }

        expect(response).to redirect_to(authorization_requests_path)
      end

      it 'allows proconnect_api_particulier' do
        get :create_from_oauth, params: { provider: 'proconnect_api_particulier' }

        expect(response).to redirect_to(authorization_requests_path)
      end
    end

    describe 'MFA reauthentication for MonComptePro users' do
      let(:mon_compte_pro_idp_id) { '71144ab3-ee1a-4401-b7b3-79b44f7daeeb' }
      let(:id_token) { JSON::JWT.new(amr: amr_values).to_s }

      let(:omniauth_auth_with_mcp) do
        OmniAuth::AuthHash.new(
          info: {
            'email' => user.email,
            'first_name' => 'John',
            'last_name' => 'Doe',
            'uid' => '123456'
          },
          extra: {
            raw_info: { 'idp_id' => idp_id, 'email' => user.email }
          }
        )
      end

      let(:idp_id) { mon_compte_pro_idp_id }

      before do
        request.env['omniauth.auth'] = omniauth_auth_with_mcp
        session['omniauth.pc.id_token'] = id_token
        allow(OmniAuth::Strategies::Proconnect).to receive(:authorization_endpoint)
          .and_return('https://proconnect.test/authorize')
      end

      context 'when user authenticated via MonComptePro without MFA' do
        let(:amr_values) { ['pwd'] }

        it 'redirects to MFA reauthentication' do
          get :create_from_oauth, params: { provider: valid_provider }

          expect(response.location).to include('proconnect.test/authorize')
        end

        it 'does not create user session' do
          get :create_from_oauth, params: { provider: valid_provider }

          expect(session[:current_user_id]).to be_nil
        end
      end

      context 'when user authenticated via MonComptePro with MFA' do
        let(:amr_values) { %w[pwd mfa] }

        it 'allows the oauth callback' do
          get :create_from_oauth, params: { provider: valid_provider }

          expect(response).to redirect_to(authorization_requests_path)
        end

        it 'creates user session' do
          get :create_from_oauth, params: { provider: valid_provider }

          expect(session[:current_user_id]).to eq(user.id)
        end
      end

      context 'when user authenticated via another IdP without MFA' do
        let(:amr_values) { ['pwd'] }
        let(:idp_id) { 'other-idp-id' }

        it 'allows the oauth callback without MFA' do
          get :create_from_oauth, params: { provider: valid_provider }

          expect(response).to redirect_to(authorization_requests_path)
        end
      end
    end
  end

  describe 'GET #dev_login' do
    shared_examples 'allows bypass login' do
      context 'when user exists' do
        let!(:user) { create(:user, email: 'test@example.com') }

        it 'signs in the user and redirects to authorization_requests_path' do
          get :dev_login, params: { email: 'test@example.com' }

          expect(session[:current_user_id]).to eq(user.id)
          expect(response).to redirect_to(authorization_requests_path)
        end

        it 'handles case-insensitive emails' do
          get :dev_login, params: { email: 'TEST@EXAMPLE.COM' }

          expect(session[:current_user_id]).to eq(user.id)
        end
      end

      context 'when user does not exist' do
        it 'redirects to root with error message' do
          get :dev_login, params: { email: 'nonexistent@example.com' }

          expect(session[:current_user_id]).to be_nil
          expect(response).to redirect_to(root_path)
          expect(flash[:error]['title']).to eq('Compte introuvable')
        end
      end

      context 'when email is not provided' do
        it 'redirects to root with error message' do
          get :dev_login

          expect(session[:current_user_id]).to be_nil
          expect(response).to redirect_to(root_path)
        end
      end
    end

    %w[development staging sandbox].each do |env|
      context "when in #{env} environment" do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(env))
        end

        it_behaves_like 'allows bypass login'
      end
    end

    context 'when in production environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'redirects to root without signing in' do
        create(:user, email: 'test@example.com')

        get :dev_login, params: { email: 'test@example.com' }

        expect(session[:current_user_id]).to be_nil
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
