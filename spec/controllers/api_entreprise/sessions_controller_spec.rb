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
  end
end
