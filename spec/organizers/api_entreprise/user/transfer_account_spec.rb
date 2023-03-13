require 'rails_helper'

RSpec.describe APIEntreprise::User::TransferAccount, type: :organizer do
  subject { described_class.call(params) }

  let!(:current_owner) { create(:user, :with_token) }

  let(:params) do
    {
      current_owner:,
      target_user_email:
    }
  end

  context 'when the email address is valid' do
    let(:target_user_email) { 'already@known.com' }

    context 'when the target user already exists' do
      let!(:target_user) { create(:user, email: target_user_email) }

      it { is_expected.to be_a_success }

      it 'gives the token ownership to the new user' do
        transfered_token_ids = current_owner.token_ids
        subject

        expect(target_user.token_ids).to include(*transfered_token_ids)
      end

      it 'keeps the existing tokens of the target user' do
        existing_tokens_id = target_user.token_ids
        subject

        expect(target_user.token_ids).to include(*existing_tokens_id)
      end

      it 'removes all token ownership from the previous user' do
        subject

        expect(current_owner.reload.tokens).to be_empty
      end

      it 'notifies the new owner by email' do
        expect(UserMailer).to receive(:transfer_ownership)
          .with(current_owner, target_user)
          .and_call_original

        subject
      end

      it 'sets new tokens have been transfered' do
        subject

        target_user.reload

        expect(target_user.tokens_newly_transfered).to be(true)
      end

      it 'does not create a new user' do
        expect { subject }.not_to change(User, :count)
      end
    end

    context 'when the new owner does not exist in database' do
      let(:target_user_email) { 'not@known.com' }

      it { is_expected.to be_success }

      it 'gives the token ownership to the new user' do
        transfered_token_ids = current_owner.token_ids
        subject
        target_user = User.find_by(email: target_user_email)

        expect(target_user.token_ids).to match_array(transfered_token_ids)
      end

      it 'removes token ownership of the previous user' do
        subject

        expect(current_owner.reload.tokens).to be_empty
      end

      it 'sends a notification email for account creation' do
        expect(UserMailer).to receive(:transfer_ownership)
          .and_call_original

        subject
      end

      it 'creates the new user record' do
        expect { subject }.to change(User, :count).by(1)
      end

      it 'creates a ghost user' do
        subject
        target_user = User.find_by(email: target_user_email)

        expect(target_user).to have_attributes({
          email: target_user_email,
          context: current_owner.context,
          oauth_api_gouv_id: nil,
          tokens_newly_transfered: true,
          confirmed?: false
        })
      end
    end
  end

  context 'when the email address is invalid' do
    let(:target_user_email) { 'not@nemail' }

    it { is_expected.to be_a_failure }

    it 'does not create a new user' do
      expect { subject }.not_to change(User, :count)
    end

    it 'does not transfer any tokens' do
      expect { subject }.not_to change(current_owner.tokens, :count)
    end

    it 'does not send email notification' do
      expect(UserMailer).not_to receive(:transfer_ownership)

      subject
    end

    it 'returns an error' do
      expect(subject.message).to eq('invalid_email')
    end
  end
end
