require 'rails_helper'

RSpec.describe(OAuthApiGouvController, type: :controller) do
  describe '#login' do
    let(:login_params) { { authorization_code: code } }

    context 'when the authorization code is valid', vcr: { cassette_name: 'oauth_api_gouv_valid_call' } do
      include_context 'oauth api gouv fresh token'
      let(:code) { OAuthApiGouv::AuthorizationCode.valid }

      context 'when the authenticated user exists' do
        let!(:user) { create(:user, :known_api_gouv_user) }

        it 'returns HTTP code 200' do
          get :login, params: login_params, as: :json

          expect(response.code).to(eq('200'))
        end

        it 'returns an access token' do
          get :login, params: login_params, as: :json

          expect(response_json).to(include(access_token: String))
        end
      end

      context 'when the authenticated user does not exist' do
        it 'returns HTTP code 422' do
          get :login, params: login_params, as: :json

          expect(response.code).to(eq('422'))
        end

        it 'returns an error message' do
          get :login, params: login_params, as: :json
          msg = response_json[:errors]

          expect(msg).to(eq('Utilisateur inconnu du service API Entreprise.'))
        end
      end

      context 'when something wrong happens requesting OAuth API Gouv', vcr: { cassette_name: 'oauth_api_gouv_invalid_client_credentials' } do
        it 'returns HTTP code 502' do
          get :login, params: login_params, as: :json

          expect(response.code).to(eq('502'))
        end

        it 'returns an error message' do
          get :login, params: login_params, as: :json
          msg = response_json[:errors]

          expect(msg).to(eq('Une erreur est survenue lors des échanges avec OAuth API Gouv. Contactez API Entreprise à support@entreprise.api.gouv.fr si le problème persiste.'))
        end
      end
    end

    context 'when authorization_code param is invalid', vcr: { cassette_name: 'oauth_api_gouv_invalid_authorization_code' } do
      let(:code) { OAuthApiGouv::AuthorizationCode.invalid }

      it 'returns HTTP code 401' do
        get :login, params: login_params, as: :json

        expect(response.code).to(eq('401'))
      end

      it 'returns an error message' do
        get :login, params: login_params, as: :json
        msg = response_json[:errors]

        expect(msg).to(eq('Erreur lors de l\'authentification : authorization code invalide.'))
      end
    end

    context 'when authorization_code format is invalid' do
      let(:code) { nil }

      it 'returns HTTP code 422' do
        get :login, params: login_params, as: :json

        expect(response.code).to(eq('422'))
      end

      it 'returns an error message' do
        get :login, params: login_params, as: :json
        msg = response_json[:errors]

        expect(msg).to(eq(authorization_code: ['must be filled']))
      end
    end
  end
end
