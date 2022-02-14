# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DatapassWebhook::FindOrCreateUser, type: :interactor do
  describe '.call' do
    subject { described_class.call(datapass_webhook_params) }

    let(:datapass_webhook_params) { build(:datapass_webhook, demandeur_attributes: demandeur_attributes) }
    let(:demandeur_attributes) do
      {
        email: generate(:email)
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

        expect(user.oauth_api_gouv_id).to be_present
        expect(user.first_name).to eq('demandeur first name')
        expect(user.last_name).to eq('demandeur last name')
        expect(user.phone_number).to be_present
        expect(user.context).to eq('13002526500013')
      end
    end

    context 'when there is already a user with the same email' do
      let!(:user) { create(:user, email: demandeur_attributes[:email]) }

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
        }.to change { user.reload.first_name }.to('demandeur first name')
      end
    end
  end
end
