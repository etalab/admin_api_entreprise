require 'rails_helper'

describe OAuthApiGouv::Tasks::RetrieveUserInfo do
  subject(:fetch_user!) { described_class.call(access_token: token) }

  context 'when the access token is valid', vcr: { cassette_name: 'oauth_api_gouv_user_info_valid_token' } do
    let(:token) { OAuthApiGouv::AccessToken.valid }

    context 'when the related user does not exist' do
      it { is_expected.to be_failure }

      it 'ends in the :unknown_user state' do
        res = fetch_user!
        state = res.event.to_h[:semantic]

        expect(state).to eq(:unknown_user)
      end
    end

    context 'when the related user exists' do
      # Here the specified ID is the one recorded in the cassette
      let!(:user) { create(:user, oauth_api_gouv_id: 5037) }

      it { is_expected.to be_success }

      it 'returns the related user record' do
        db_user = fetch_user![:user]

        expect(db_user).to eq(user)
      end

      it 'returns a JWT to access to the dashboard' do
        dashboard_token = fetch_user![:dashboard_token]

        expect(dashboard_token).to match(/.+\..+\..+/)
      end
    end
  end

  context 'when the access token is not valid', vcr: { cassette_name: 'oauth_api_gouv_user_info_invalid_token' } do
    let(:token) { 'LET.ME.IN' }

    it { is_expected.to be_failure }

    it 'ends in the :failure state' do
      res = fetch_user!
      state = res.event.to_h[:semantic]

      expect(state).to eq(:failure)
    end

    it 'logs the error' do
      expect(Rails.logger).to receive(:error)
        .with(a_string_matching(/OAuth User Info call failed: status \d+, description .+/))

      fetch_user!
    end
  end
end
