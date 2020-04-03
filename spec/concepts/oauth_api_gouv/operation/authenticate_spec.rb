require 'rails_helper'

describe OAuthApiGouv::Operation::Authenticate do
  subject(:authenticate!) { described_class.call(authorization_code: code) }

  context 'when the authorization code is valid' do
    let(:code) { '4Z4DB7FEr405jLYEA2teJctiMkIvgOwEBvejwZfU0X9' }

    context 'when Admin API credentials are valid', vcr: { cassette_name: 'oauth_api_gouv_valid_call' } do
      # Time when the recorded ID Token hasn't expired yet
      let(:id_token_alive_time) { Time.at(1585921500) }

      context 'when the ID Token is valid' do
        before { Timecop.freeze(id_token_alive_time) }

        it 'returns an Access Token' do
          access_token = authenticate![:access_token]

          expect(access_token).to be_a(String)
        end

        it 'returns an ID Token' do
          id_token = authenticate![:access_token]

          expect(id_token).to be_a(String)
        end

        it { is_expected.to be_success }

        it 'returns the user ID (from OAuth API Gouv)' do
          user_id = authenticate![:oauth_api_gouv_user_id]

          expect(user_id).to be_an(Integer)
        end

        after { Timecop.return }
      end

      context 'when the ID Token is not valid' do
        shared_examples :jwt_validation_failure do
          it { is_expected.to be_failure }

          it 'ends in the :failure' do
            res = authenticate!
            state = res.event.to_h[:semantic]

            expect(state).to eq(:failure)
          end
        end

        describe 'invalid signature' do
          # Here we provide an invalid ID Token on code execution
          before do
            allow(AccessToken).to receive(:decode_oauth_api_gouv_id_token)
              .and_wrap_original { |m, jwt, jwks| m.call(OAuthApiGouv::ForgedJWT.invalid_signature, jwks) }
          end

          it_behaves_like :jwt_validation_failure

          it 'logs the error' do
            expect(Rails.logger).to receive(:error)
              .with('ID Token verification error: Signature verification raised')

            authenticate!
          end
        end

        describe 'invalid audience' do
          # No way to forge the JWT with another 'aud' claim, so let's use the
          # valid JWT and modify the expected audience value instead
          before do
            Timecop.freeze(id_token_alive_time)
            allow(Rails.configuration).to receive(:oauth_api_gouv_client_id).and_return('lol audience')
          end

          it_behaves_like :jwt_validation_failure

          it 'logs the error' do
            expect(Rails.logger).to receive(:error)
              .with(a_string_starting_with('ID Token verification error: Invalid audience. Expected lol audience, received'))

            authenticate!
          end

          after { Timecop.return }
        end

        describe 'invalid issuer' do
          # No way to forge the JWT with another 'iss' claim, so let's use the
          # valid JWT and modify the expected issuer value instead
          before do
            Timecop.freeze(id_token_alive_time)
            allow(Rails.configuration).to receive(:oauth_api_gouv_issuer).and_return('lol issuer')
          end

          it_behaves_like :jwt_validation_failure

          it 'logs the error' do
            expect(Rails.logger).to receive(:error)
              .with(a_string_starting_with('ID Token verification error: Invalid issuer. Expected lol issuer, received'))

            authenticate!
          end

          after { Timecop.return }
        end

        # ID tokens expire in 3h, let's run the test with a valid one
        # freezing the time 4 hours later
        describe 'expired id token' do
          before { Timecop.freeze(Time.zone.now + 14400) }

          it_behaves_like :jwt_validation_failure

          it 'logs the error' do
            expect(Rails.logger).to receive(:error)
              .with(a_string_starting_with('ID Token verification error: Signature has expired'))

            authenticate!
          end

          after { Timecop.return }
        end
      end
    end

    context 'when Admin API credentials are not valid', vcr: { cassette_name: 'oauth_api_gouv_invalid_client_credentials' } do
      before do
        allow(Rails.application.secrets).to receive(:oauth_api_gouv_client_secret)
          .and_return('lecodecestlecode')
      end

      it { is_expected.to be_failure }

      it 'logs the error' do
        expect(Rails.logger).to receive(:error)
          .with('OAuth API Gouv call failed: status 401, description {"error":"invalid_client","error_description":"client authentication failed"}')

        authenticate!
      end

      it 'ends in the :failure state' do
        res = authenticate!
        state = res.event.to_h[:semantic]

        expect(state).to eq(:failure)
      end
    end
  end

  context 'when the authorization code is invalid', vcr: { cassette_name: 'oauth_api_gouv_invalid_authorization_code' } do
    let(:code) { 'coucode' }

    it { is_expected.to be_failure }

    it 'logs the error' do
      expect(Rails.logger).to receive(:error)
        .with('OAuth API Gouv call failed: status 400, description {"error":"invalid_grant","error_description":"grant request is invalid"}')

      authenticate!
    end

    it 'ends in the :invalid_authorization_code state' do
      res = authenticate!
      state = res.event.to_h[:semantic]

      expect(state).to eq(:invalid_authorization_code)
    end
  end
end
