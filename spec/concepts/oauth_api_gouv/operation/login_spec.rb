require 'rails_helper'

RSpec.describe OAuthAPIGouv::Operation::Login, type: :jwt do
  let(:op_params) do
    { authorization_code: code }
  end

  subject(:login!) { described_class.call(params: op_params) }

  context 'when the authorization code is valid', vcr: { cassette_name: 'oauth_api_gouv_valid_call' } do
    include_context 'oauth api gouv fresh token'
    let(:code) { OAuthAPIGouv::AuthorizationCode.valid }

    context 'when the authenticated user exists' do
      let!(:user) { create(:user, :known_api_gouv_user) }

      it { is_expected.to be_success }

      it 'returns a valid JWT to access the dashboard' do
        dashboard_jwt = login![:dashboard_token]
        jwt_payload = extract_payload_from(dashboard_jwt)

        expect(jwt_payload).to include({
          uid: user.id,
          iat: Integer,
          exp: Integer
        })
      end
    end

    context 'when the authenticated user does not exist' do
      it { is_expected.to be_failure }

      it 'ends in the :unknown_user state' do
        state = login!.event.to_h[:semantic]

        expect(state).to eq(:unknown_user)
      end
    end

    # Internal communication error with OAuth API Gouv (bad client secrets for instance)
    context 'when an internal error occurs', vcr: { cassette_name: 'oauth_api_gouv_invalid_client_credentials' } do
      it { is_expected.to be_failure }

      it 'ends in the :failure state' do
        state = login!.event.to_h[:semantic]

        expect(state).to eq(:failure)
      end
    end
  end

  context 'when the authorization code is not valid', vcr: { cassette_name: 'oauth_api_gouv_invalid_authorization_code' } do
    let(:code) { OAuthAPIGouv::AuthorizationCode.invalid }

    it { is_expected.to be_failure }

    it 'ends in the :invalid_authorization_code state' do
      state = login!.event.to_h[:semantic]

      expect(state).to eq(:invalid_authorization_code)
    end
  end

  describe 'params validation' do
    let(:code) { 'random' }

    describe 'authorization_code' do
      let(:errors) { login!['result.contract.default'].errors.to_h }

      it 'is required' do
        op_params.delete(:authorization_code)
        final_state = login!.event.to_h[:semantic]

        expect(login!).to be_failure
        expect(final_state).to eq(:invalid_params)
        expect(errors).to include(authorization_code: ['is missing'])
      end

      it 'is a string' do
        op_params[:authorization_code] = 123
        final_state = login!.event.to_h[:semantic]

        expect(login!).to be_failure
        expect(final_state).to eq(:invalid_params)
        expect(errors).to include(authorization_code: ['must be a string'])
      end
    end
  end
end
