require 'rails_helper'

describe OAuthApiGouv::Tasks::RetrieveAccessToken do
  subject(:retrieve_tokens!) { described_class.call(authorization_code: code) }

  context 'when the authorization code is valid' do
    let(:code) { OAuthApiGouv::AuthorizationCode.valid }

    context 'when Admin API credentials are valid', vcr: { cassette_name: 'oauth_api_gouv_valid_call' } do
      context 'when the ID Token is valid' do
        include_context 'oauth api gouv fresh token'

        it 'returns an Access Token' do
          access_token = retrieve_tokens![:access_token]

          expect(access_token).to be_a(String)
        end

        it 'returns an ID Token' do
          id_token = retrieve_tokens![:access_token]

          expect(id_token).to be_a(String)
        end

        it { is_expected.to be_success }

        it 'returns the user ID (from OAuth API Gouv)' do
          user_id = retrieve_tokens![:oauth_api_gouv_user_id]

          expect(user_id).to be_an(Integer)
        end
      end

      context 'when the ID Token is not valid' do
        shared_examples :jwt_validation_failure do
          it { is_expected.to be_failure }

          it 'ends in the :failure' do
            res = retrieve_tokens!
            state = res.event.to_h[:semantic]

            expect(state).to eq(:failure)
          end
        end

        describe 'invalid signature' do
          # Here we provide an invalid ID Token on code execution
          before do
            allow(AccessToken).to receive(:decode_oauth_api_gouv_id_token)
              .and_wrap_original { |m, jwt, jwks| m.call(OAuthApiGouv::IdToken.invalid_signature, jwks) }
          end

          it_behaves_like :jwt_validation_failure

          it 'logs the error' do
            expect(Rails.logger).to receive(:error)
              .with('ID Token verification error: Signature verification raised')

            retrieve_tokens!
          end
        end

        describe 'invalid audience' do
          include_context 'oauth api gouv fresh token'
          # No way to forge the JWT with another 'aud' claim, so let's use the
          # valid JWT and modify the expected audience value instead
          before do
            allow(Rails.configuration).to receive(:oauth_api_gouv_client_id).and_return('lol audience')
          end

          it_behaves_like :jwt_validation_failure

          it 'logs the error' do
            expect(Rails.logger).to receive(:error)
              .with(a_string_starting_with('ID Token verification error: Invalid audience. Expected lol audience, received'))

            retrieve_tokens!
          end
        end

        describe 'invalid issuer' do
          include_context 'oauth api gouv fresh token'
          # No way to forge the JWT with another 'iss' claim, so let's use the
          # valid JWT and modify the expected issuer value instead
          before do
            allow(Rails.configuration).to receive(:oauth_api_gouv_issuer).and_return('http://www.issuer.fr')
          end

          it_behaves_like :jwt_validation_failure

          it 'logs the error' do
            expect(Rails.logger).to receive(:error)
              .with(a_string_starting_with('ID Token verification error: Invalid issuer. Expected http://www.issuer.fr, received'))

            retrieve_tokens!
          end
        end

        # ID tokens expire in 3h, let's run the test with a valid one
        # freezing the time 4 hours later
        describe 'expired id token' do
          before { Timecop.freeze(Time.zone.now + 4.hours) }

          it_behaves_like :jwt_validation_failure

          it 'logs the error' do
            expect(Rails.logger).to receive(:error)
              .with(a_string_starting_with('ID Token verification error: Signature has expired'))

            retrieve_tokens!
          end

          after { Timecop.return }
        end
      end
    end

    context 'when Admin API credentials are not valid', vcr: { cassette_name: 'oauth_api_gouv_invalid_client_credentials' } do
      before do
        allow(Rails.application.credentials).to receive(:oauth_api_gouv_client_secret)
          .and_return('lecodecestlecode')
      end

      it { is_expected.to be_failure }

      it 'logs the error' do
        expect(Rails.logger).to receive(:error)
          .with('OAuth API Gouv call failed: status 401, description {"error":"invalid_client","error_description":"client authentication failed"}')

        retrieve_tokens!
      end

      it 'ends in the :failure state' do
        res = retrieve_tokens!
        state = res.event.to_h[:semantic]

        expect(state).to eq(:failure)
      end
    end
  end

  context 'when the authorization code is invalid', vcr: { cassette_name: 'oauth_api_gouv_invalid_authorization_code' } do
    let(:code) { OAuthApiGouv::AuthorizationCode.invalid }

    it { is_expected.to be_failure }

    it 'logs the error' do
      expect(Rails.logger).to receive(:error)
        .with('OAuth API Gouv call failed: status 400, description {"error":"invalid_grant","error_description":"grant request is invalid"}')

      retrieve_tokens!
    end

    it 'ends in the :invalid_authorization_code state' do
      res = retrieve_tokens!
      state = res.event.to_h[:semantic]

      expect(state).to eq(:invalid_authorization_code)
    end
  end
end
