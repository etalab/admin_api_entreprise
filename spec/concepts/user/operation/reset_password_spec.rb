require 'rails_helper'

describe User::Operation::ResetPassword do
  let(:user) { create(:user, pwd_renewal_token: 'coucou') }
  let(:reset_params) do
    {
      token: user.pwd_renewal_token,
      password: 'alloROGER12',
      password_confirmation: 'alloROGER12'
    }
  end

  subject { described_class.call(params: reset_params) }

  describe 'params validation' do
    let(:errors) { subject[:'result.contract.default'].errors }

    describe ':token' do
      it 'is required' do
        reset_params[:token] = nil
        subject

        expect(subject).to be_failure
        expect(errors[:token]).to include('must be filled')
      end

      it 'must exists in database' do
        reset_params[:token] = 'ghost'
        subject

        expect(subject).to be_failure
        expect(errors[:token]).to include('Le lien de régénération de mot de passe est invalide')
      end
    end

    describe ':password' do
      it_behaves_like :password_renewal_contract
    end
  end

  describe 'password reset logic' do
    context 'when the token has not expired' do
      before { user.update(pwd_renewal_token_sent_at: 12.hours.ago) }

      it { is_expected.to be_success }

      it 'sets the new password' do
        user = subject[:user]

        expect(user.authenticate(reset_params[:password])).to be_truthy
      end

      it 'expires the token' do
        user = subject[:user]

        expect(user.pwd_renewal_token).to eq(nil)
      end
    end

    context 'when the token has expired' do
      before { user.update(pwd_renewal_token_sent_at: 25.hours.ago) }

      it { is_expected.to be_failure }

      it 'does not change the password' do
        user = subject[:user]

        expect(user.authenticate(reset_params[:password])).to eq(false)
      end

      it 'returns an error' do
        err_msg = subject[:errors]

        expect(err_msg).to eq('Le lien de renouvellement de mot de passe a expiré')
      end
    end
  end
end
