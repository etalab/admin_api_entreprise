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
      subject do
        result = described_class.call(params: user_params)
        result[:model]
      end

      its(:email) { is_expected.to eq(user_params[:email]) }
      its(:context) { is_expected.to eq(user_params[:context]) }
      its(:password_digest) { is_expected.to be_blank }
      its(:confirmation_token) { is_expected.to match(/\A[0-9a-f]{20}\z/) }
      its(:confirmed?) { is_expected.to eq(false) }

      it 'sets the confirmation request timestamp' do
        Timecop.freeze
        confirmation_sent_time = subject.confirmation_sent_at.to_i

        expect(confirmation_sent_time).to eq(Time.zone.now.to_i)
        Timecop.return
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
