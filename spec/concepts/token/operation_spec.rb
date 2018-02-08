require 'rails_helper'

describe Token::Create do
  let(:user) { create :user }
  let(:token_params) do
    {
      user_id: user.id,
      roles: %w(rol1 rol2 rol3)
    }
  end
  let(:result) { described_class.call(token_params) }

  context 'when data is valid' do
    it 'persists valid' do
      expect(result).to be_success
      expect(result['created_token']).to be_persisted
      expect(result['created_token'].user).to eq user
    end
  end

  context 'when data is invalid' do
    describe ':roles' do
      let(:errors) { result['result.contract.params'].errors[:roles] }

      it 'is required' do
        token_params[:roles] = []

        expect(result).to be_failure
        expect(errors).to include 'must be filled'
      end

      pending 'roles into payload must exists in database'
    end

    describe ':user_id' do
      let(:errors) { result['result.contract.params'].errors[:user_id] }

      it 'is required' do
        token_params.delete(:user_id)

        expect(result).to be_failure
        expect(errors).to include('is missing')
      end

      it 'is an existing user id' do
        token_params[:user_id] = 'not a user id'

        expect(result).to be_failure
        expect(result['errors']).to eq("user does not exist (UID : 'not a user id')")
      end
    end
  end

  describe 'issued token' do
    # TODO spec for issued tokens format
  end
end
