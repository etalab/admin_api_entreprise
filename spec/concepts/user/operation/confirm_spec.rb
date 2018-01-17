require 'rails_helper'

describe User::Confirm do
  let(:result) { described_class.call(confirmation_params) }
  let(:inactive_user) { UsersFactory.inactive_user }
  let(:confirmation_params) do
    {
      password: 'couCOU23',
      password_confirmation: 'couCOU23',
      confirmation_token: inactive_user.confirmation_token
    }
  end

  describe 'user confirmation logic' do
    context 'when user is not already confirmed' do
      it 'confirmation_token params must refer to an unconfirmed user' do
        confirmation_params[:confirmation_token] = 'invalid token'

        expect(result).to be_failure
        expect(result['errors']).to include 'invalid token'
      end

      it 'confirms the user' do
        expect(result).to be_success
        expect(result['model']).to be_confirmed
      end

      it 'sets the user password' do
        expect(result['model'].password_digest).to_not eq ''
        expect(!!result['model'].authenticate(confirmation_params[:password]))
          .to be true
      end

      it 'sends a notification email to the user'
    end

    context 'when user is already confirmed' do
      # TODO mock this the right way
      # allow_any_instance_of(User).to receive(:confirmed?).and_return(true)
      # did not worked because .confirmation_token then return nil
      before { described_class.call(confirmation_params) }

      it 'fails with error message' do
        expect(result).to be_failure
        expect(result['errors']).to include 'user already confirmed'
      end

      it 'does not change the password' do
        old_password = confirmation_params[:password]
        confirmation_params[:password] =
          confirmation_params[:password_confirmation] = 'newPAssw0rd'

        expect(result).to be_failure
        expect(!!result['model'].authenticate(old_password))
          .to be true
      end
    end
  end

  describe 'params validation contract' do
    describe '#confirmation_token' do
      it 'is required' do
        confirmation_params[:confirmation_token] = ''
        contract_error = result['result.contract.params']
          .errors[:confirmation_token]

        expect(result).to be_failure
        expect(contract_error).to include 'must be filled'
      end
    end

    describe '#password' do
      let(:contract_error) { result['result.contract.params'].errors[:password] }
      let(:format_error_message) { 'minimum eight characters, at least one uppercase letter, one lowercase letter and one number' }

      it 'must match confirmation' do
        confirmation_params[:password_confirmation] = 'coucou23'

        expect(result).to be_failure
        expect(result['result.contract.params']
          .errors[:password_confirmation])
          .to include 'must be equal to password'
      end

      it 'is min 8 characters long' do
        confirmation_params[:password] =
          confirmation_params['password_confirmation'] = 'a' * 7

        expect(contract_error).to include 'size cannot be less than 8'
      end

      it 'contains a lowercase letter' do
        confirmation_params[:password] =
          confirmation_params['password_confirmation'] = 'AAAAAAAAA3'
        expect(contract_error).to include format_error_message
      end

      it 'contains an uppercase letter' do
        confirmation_params[:password] =
          confirmation_params['password_confirmation'] = 'aaaaaaaaa3'
        expect(contract_error).to include format_error_message
      end

      it 'contains a number' do
        confirmation_params[:password] =
          confirmation_params['password_confirmation'] = 'AAAAAAAAAa'
        expect(contract_error).to include format_error_message
      end
    end
  end
end
