require 'rails_helper'

RSpec.describe APIParticulier::User::Login, type: :organizer do
  subject(:sync!) { described_class.call(params) }

  let(:params) do
    {
      oauth_api_gouv_email: user.email,
      oauth_api_gouv_id:
    }
  end

  context 'when the user does not exist' do
    let(:user) { build(:user) }
    let(:oauth_api_gouv_id) { 'whatever' }

    it { is_expected.to be_a_failure }
  end

  context 'when the user exists in the database' do
    let(:user) { create(:user) }
    let(:oauth_api_gouv_id) { user.oauth_api_gouv_id }

    it { is_expected.to be_a_success }

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
  end
end
