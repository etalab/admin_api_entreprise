require 'rails_helper'

# rubocop:disable RSpec/FilePath
RSpec.describe User::Login, type: :organizer do
  subject(:sync!) { described_class.call(params) }

  let(:params) do
    {
      oauth_api_gouv_email: user.email,
      oauth_api_gouv_id: oauth_api_gouv_id,
    }
  end

  context 'when the user does not exist' do
    let(:user) { build(:user) }
    let(:oauth_api_gouv_id) { 'whatever' }

    it { is_expected.to be_a_failure }
  end

  context 'when the user exists in the database' do
    context 'when the user does not have a known API Gouv ID' do
      let(:user) { create(:user, oauth_api_gouv_id: nil) }
      let(:oauth_api_gouv_id) { '1234' }

      it { is_expected.to be_a_success }

      it 'updates the OAuth API Gouv ID for the user' do
        sync!
        user.reload

        expect(user.oauth_api_gouv_id).to eq(oauth_api_gouv_id)
      end
    end

    context 'when the user signs in after receiving new tokens' do
      let(:user) { create(:user, :new_token_owner) }
      let(:oauth_api_gouv_id) { user.oauth_api_gouv_id }

      it { is_expected.to be_a_success }

      it 'sends an email to datapass for authorization request ownership update' do
        expect { sync! }
          .to have_enqueued_mail(UserMailer, :notify_datapass_for_data_reconciliation)
          .with(args: [user])
      end

      it 'does not send emails on second login' do
        sync!

        expect { sync! }
          .not_to have_enqueued_mail(UserMailer, :notify_datapass_for_data_reconciliation)
      end
    end
  end
end
# rubocop:enable RSpec/FilePath
