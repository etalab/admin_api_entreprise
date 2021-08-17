# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::FindOrCreateUser, type: :interactor do
  describe '.call' do
    subject { described_class.call(datapass_webhook_params) }

    let(:datapass_webhook_params) { build(:datapass_webhook, user_attributes: user_attributes) }
    let(:user_attributes) do
      {
        email: generate(:email),
      }
    end

    context 'when there is no user with the same email' do
      it { is_expected.to be_a_success }
      it { expect(subject.user).to an_instance_of(User) }

      it 'creates a new user with valid attributes' do
        expect {
          subject
        }.to change { User.count }.by(1)

        user = User.last
        expect(user.oauth_api_gouv_id).to eq(datapass_webhook_params['data']['pass']['user']['uid'])
        expect(user.first_name).to eq('John')
        expect(user.last_name).to eq('Doe')
      end
    end

    context 'when there is already a user with the same email' do
      let!(:user) { create(:user, email: user_attributes[:email]) }

      it { is_expected.to be_a_success }
      it { expect(subject.user).to eq(user) }

      it 'does not create a new user' do
        expect {
          subject
        }.not_to change { User.count }
      end

      it 'updates existing user with attributes' do
        expect {
          subject
        }.to change { user.reload.first_name }.to('John')
      end
    end
  end
end
