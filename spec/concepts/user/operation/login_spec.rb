require 'rails_helper'

describe User::Operation::Login do
  let(:result) { described_class.call(params: login_params) }

  context 'when user email is unknown' do
    let(:login_params) do
      { username: 'unknownem@il.bad', password: 'couCOU123' }
    end

    it 'fails authentication' do
      expect(result).to be_failure
    end
  end

  context 'when user email is valid' do
    let(:login_params) do
      { username: user.email, password: user.password }
    end

    let(:user) { create(:user) }

    context 'when password is invalid' do
      it 'fails authentication' do
        login_params[:password] = 'invalid password'

        expect(result).to be_failure
      end

      it 'increments counter before lock'
    end

    context 'when incomming params are valid' do
      it 'returns the user' do
        expect(result).to be_success
        expect(result[:model]).to eq user
      end

      it 'resets counter before lock'
    end

    context 'with empty spaces around email' do
      it 'strips spaces' do
        user.email = '   ' + user.email + '    '
        expect(result).to be_success
      end
    end

    context 'when user is locked' do
      it 'fails authentication'
    end
  end
end
