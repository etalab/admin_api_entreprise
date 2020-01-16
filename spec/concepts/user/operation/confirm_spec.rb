require 'rails_helper'

describe User::Operation::Confirm do
  let(:result) { described_class.call(params: confirmation_params) }
  let(:inactive_user) { UsersFactory.inactive_user }
  let(:confirmation_params) do
    {
      password: 'couCOU23',
      password_confirmation: 'couCOU23',
      confirmation_token: inactive_user.confirmation_token,
    }
  end

  describe 'user confirmation logic' do
    context 'when user is not already confirmed' do
      it 'confirmation_token params must refer to an unconfirmed user' do
        confirmation_params[:confirmation_token] = 'invalid token'

        expect(result).to be_failure
        expect(result[:errors]).to include confirmation_token: ['confirmation token not found']
      end

      it 'confirms the user' do
        expect(result).to be_success
        expect(result[:model]).to be_confirmed
      end

      it 'sets the user password' do
        expect(result[:model].password_digest).to_not eq ''
        expect(!!result[:model].authenticate(confirmation_params[:password]))
          .to be true
      end

      it 'returns a session JWT for user dashboard access' do
        expect(result['access_token']).to be_truthy
      end

      it 'sends a notification email to the user'
    end

    context 'when user is already confirmed' do
      # TODO mock this the right way
      # allow_any_instance_of(User).to receive(:confirmed?).and_return(true)
      # did not worked because .confirmation_token then return nil
      before { described_class.call(params: confirmation_params) }

      it 'fails with error message' do
        expect(result).to be_failure
        expect(result[:errors]).to include confirmation_token: ['user already confirmed']
      end

      it 'does not change the password' do
        old_password = confirmation_params[:password]
        confirmation_params[:password] =
          confirmation_params[:password_confirmation] = 'newPAssw0rd'

        expect(result).to be_failure
        user = User.find_by(confirmation_token: confirmation_params[:confirmation_token])
        expect(user.authenticate(old_password)).to be_truthy
      end
    end
  end

  describe 'params validation contract' do
    describe '#confirmation_token' do
      it 'is required' do
        confirmation_params[:confirmation_token] = ''

        expect(result).to be_failure
        expect(result[:errors]).to include confirmation_token: ['must be filled']
      end

      it 'must exist' do
        confirmation_params[:confirmation_token] = 'you will never find me'
        expect(result).to be_failure
        expect(result[:errors]).to include confirmation_token: ['confirmation token not found']
      end
    end

    describe ':password' do
      it_behaves_like :password_renewal_contract
    end
  end
end
