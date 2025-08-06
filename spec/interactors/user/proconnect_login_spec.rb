# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::ProconnectLogin, type: :interactor do
  describe '.call' do
    subject { described_class.call(user_params: proconnect_user_params) }

    let(:proconnect_user_params) do
      {
        'email' => user_email,
        'first_name' => 'John',
        'last_name' => 'Doe',
        'uid' => uid
      }
    end
    let(:user_email) { generate(:email) }
    let(:uid) { SecureRandom.uuid }

    context 'when there is no user with the same email' do
      it { is_expected.to be_a_success }
      it { expect(subject.user).to be_an_instance_of(User) }

      it 'creates a new user with valid attributes' do
        expect {
          subject
        }.to change(User, :count).by(1)

        user = User.last

        expect(user.email).to eq(user_email)
        expect(user.first_name).to eq('John')
        expect(user.last_name).to eq('Doe')
        expect(user.oauth_api_gouv_id).to eq(uid)
      end
    end

    context 'when there is already a user with the same email' do
      let!(:existing_user) { create(:user, email: user_email) }

      it { is_expected.to be_a_success }
      it { expect(subject.user).to eq(existing_user) }

      it 'does not create a new user' do
        expect {
          subject
        }.not_to change(User, :count)
      end

      it 'returns the existing user' do
        expect(subject.user).to eq(existing_user)
      end

      it 'changes the existing user attributes' do
        expect {
          subject
          existing_user.reload
        }.to change(existing_user, :first_name).to('John')
          .and change(existing_user, :last_name).to('Doe')
          .and change(existing_user, :oauth_api_gouv_id).to(uid)
      end
    end
  end
end
