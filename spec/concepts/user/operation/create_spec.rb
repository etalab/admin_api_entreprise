require 'rails_helper'

describe User::Create do
  let(:result) { described_class.call(user_params) }
  let(:user_params) do
    {
      email: 'new@record.gg',
      context: 'very development',
      contacts: [
        {
          email: 'coucou@hello.fr',
          phone_number: '0123456789',
          contact_type: 'tech'
        },
        {
          email: 'supsup@hi.yo',
          phone_number: nil,
          contact_type: 'other'
        }
      ]
    }
  end

  context 'when params are valid' do
    it 'creates the new user' do
      expect { result }.to change(User, :count).by(1)
      expect(result).to be_success
    end
  end

  context 'when params are invalid' do
    describe '#email' do
      let(:errors) do
        result['result.contract.default'].errors.messages[:email]
      end

      it 'is required' do
        user_params[:email] = ''
        expect(result).to be_failure
        expect(errors).to include 'must be filled'
      end

      it 'has an email format' do
        user_params[:email] = 'verymail'
        expect(result).to be_failure
        expect(errors).to include 'is in invalid format'
      end

      it 'is unique'
    end

    describe '#context' do
      let(:errors) do
        result['result.contract.default'].errors.messages[:context]
      end

      it 'can be blank' do
        user_params[:context] = ''
        expect(result).to be_success
        expect(errors).to be_nil
      end
    end

    describe '#contacts' do
      it 'is not valid if contact\'s data is not valid' do
        user_params[:contacts].append(email: 'not an email')
        expect(result).to be_failure
      end

      it 'is optionnal' do
        user_params.delete :contacts
        expect(result).to be_success
      end
    end

    describe 'account created state' do
      let(:created_user) { result['model'] }

      pending 'sets the password to an empty string'

      pending 'sets a token for future email confirmation'

      pending 'is not confirmed' do
        expect(created_user).to_not be_confirmed
      end

      it 'sends a confirmation email to the user'
    end
  end
end
