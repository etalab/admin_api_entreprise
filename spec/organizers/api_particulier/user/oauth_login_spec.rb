require 'rails_helper'

RSpec.describe APIParticulier::User::OAuthLogin, type: :organizer do
  subject(:sync!) { described_class.call(params) }

  let(:params) do
    {
      oauth_api_gouv_email: user.email,
      oauth_api_gouv_id:,
      oauth_api_gouv_info:
    }
  end

  let(:oauth_api_gouv_info) do
    OmniAuth::AuthHash::InfoHash.new(
      email: user.email,
      family_name: user.last_name,
      given_name: user.first_name,
      phone_number: user.phone_number,
      sub: user.oauth_api_gouv_id || unknown_api_gouv_id
    )
  end

  let(:unknown_api_gouv_id) { '9001' }

  context 'when the user does not exist' do
    let(:user) { build(:user, :with_full_name) }
    let(:oauth_api_gouv_id) { 'whatever' }

    it { is_expected.to be_a_success }

    it 'creates a user with valid attributes' do
      expect {
        subject
      }.to change(User, :count).by(1)

      latest_user = User.last

      %w[email first_name last_name phone_number].each do |attr|
        expect(latest_user.send(attr)).to eq(user.send(attr))
      end
    end
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
