require 'rails_helper'

RSpec.describe(User::Operation::AskPasswordRenewal) do
  let(:op_params) { { email: account_email } }

  subject(:pwd_renewal_request) { described_class.call(params: op_params) }

  describe 'Input parameters' do
    let(:account_email) { 'test' }

    describe ':email' do
      it 'is required' do
        op_params[:email] = nil
        err_msg = pwd_renewal_request[:errors][:email]

        expect(pwd_renewal_request).to(be_failure)
        expect(err_msg).to(include('must be filled'))
      end

      it 'must identify an existing user' do
        err_msg = pwd_renewal_request[:errors][:email]

        expect(pwd_renewal_request).to(be_failure)
        expect(err_msg).to(include("user with email \"#{account_email}\" does not exist"))
      end
    end
  end

  context 'when a user is found for the given email' do
    let(:user) { create(:user) }
    let(:account_email) { user.email }

    it { is_expected.to(be_success) }

    it 'sets a renewal token for the user' do
      pwd_renewal_request
      user.reload

      expect(user.pwd_renewal_token).to(match(/\A[0-9a-f]{20}\z/))
    end

    it 'sets the timestamp the link has been sent at' do
      Timecop.freeze
      pwd_renewal_request
      user.reload

      expect(user.pwd_renewal_token_sent_at.to_i).to(eq(Time.zone.now.to_i))
      Timecop.return
    end

    it 'sends a password renewal email' do
      allow(UserMailer).to(receive(:renew_account_password))
      expect(UserMailer).to(receive(:renew_account_password)
        .with(an_object_having_attributes(email: account_email, class: User))
        .and_call_original)

      pwd_renewal_request
    end
  end
end
