require 'rails_helper'

describe User::Operation::Create do
  let(:user_email) { 'new@record.gg' }
  let(:user_params) do
    {
      email: user_email,
      context: 'very development'
    }
  end

  subject { described_class.call(params: user_params) }

  context 'when params are valid' do
    let(:new_user) { subject[:model] }

    it { is_expected.to be_success }

    it 'creates a new user' do
      expect { subject }.to change(User, :count).by(1)
      expect(new_user).to be_persisted
    end

    describe 'created user' do
      it 'has the given email' do
        expect(new_user.email).to eq(user_params[:email])
      end

      it 'has the given context' do
        expect(new_user.context).to eq(user_params[:context])
      end

      it 'sets the password to an empty string' do
        expect(new_user.password_digest).to eq ''
      end

      it 'sets a token for future email confirmation' do
        expect(new_user.confirmation_token).to match(/\A[0-9a-f]{20}\z/)
      end

      it 'is not confirmed' do
        expect(new_user).to_not be_confirmed
      end

      it 'sets the confirmation request timestamp' do
        expect(new_user.confirmation_sent_at.to_i)
          .to be_within(2).of(Time.zone.now.to_i)
      end
    end

    it 'sends an account confirmation email to the account owner' do
        allow(UserMailer).to receive(:confirm_account_action).and_call_original
        expect(UserMailer).to receive(:confirm_account_action)
          .with(an_object_having_attributes(email: user_email, class: User))

        subject
    end
  end

  context 'when params are invalid' do
    describe '#email' do
      let(:errors) do
        subject['result.contract.default'].errors.messages[:email]
      end

      it 'is required' do
        user_params[:email] = ''

        expect(subject).to be_failure
        expect(errors).to include 'must be filled'
      end

      it 'has an email format' do
        user_params[:email] = 'verymail'

        expect(subject).to be_failure
        expect(errors).to include 'is in invalid format'
      end

      it 'is unique' do
        user = create(:user)
        user_params[:email] = user.email

        expect(subject).to be_failure
        expect(errors).to include 'value already exists'
      end

      it 'is saved lowercase' do
        user_params[:email] = 'COUCOU@COUCOU.FR'

        expect(subject).to be_success
        expect(subject[:model].email).to eq 'coucou@coucou.fr'
      end
    end

    describe '#context' do
      let(:errors) do
        subject['result.contract.default'].errors.messages[:context]
      end

      it 'can be blank' do
        user_params[:context] = ''

        expect(subject).to be_success
        expect(errors).to be_nil
      end
    end

  end
end
