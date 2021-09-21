require 'rails_helper'

RSpec.describe OAuthAPIGouv::Tasks::RetrieveUserInfo do
  subject(:fetch_user!) { described_class.call(access_token: token) }

  context 'when the access token is valid', vcr: { cassette_name: 'oauth_api_gouv_user_info_valid_token' } do
    let(:token) { OAuthAPIGouv::AccessToken.valid }

    context 'when the related user does not exist' do
      it { is_expected.to be_failure }

      it 'ends in the :unknown_user state' do
        res = fetch_user!
        state = res.event.to_h[:semantic]

        expect(state).to eq(:unknown_user)
      end
    end

    context 'when the related user exists' do
      let!(:user) { create(:user, :known_api_gouv_user) }

      it { is_expected.to be_success }

      it 'returns the related user record' do
        db_user = fetch_user![:user]

        expect(db_user).to eq(user)
      end

      context 'when the user is not confirmed yet (:oauth_api_gouv_id unknown)' do
        before { user.update(oauth_api_gouv_id: nil) }

        let(:hard_coded_id_in_cassette) { '5037' }

        it 'updates the :oauth_api_gouv_id' do
          fetch_user!
          user.reload

          expect(user.oauth_api_gouv_id).to eq(hard_coded_id_in_cassette)
        end

        describe 'non-regression test' do
          it 'does not send any email to DataPass' do
            expect(UserMailer).to_not receive(:notify_datapass_for_data_reconciliation)

            fetch_user!
          end
        end
      end

      context 'when the user has been delegated new tokens' do
        before { user.update(tokens_newly_transfered: true) }

        it 'updates #tokens_newly_transfered to false' do
          fetch_user!
          user.reload

          expect(user.tokens_newly_transfered).to eq(false)
        end

        # This is temporary, right now DataPass ensures manually our user
        # tokens are linked to the appropriate access requests (the information
        # might be loss for DataPass after a user account has been transfered
        it 'sends an email to the DataPass support team' do
          expect(UserMailer).to receive(:notify_datapass_for_data_reconciliation)
            .with(user)
            .and_call_original

          fetch_user!
        end
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
