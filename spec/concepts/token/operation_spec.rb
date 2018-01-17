require 'rails_helper'

describe Token::Create do
  let(:user) { create :user }
  let(:token_params) do
    { token_payload: %w(rol1 rol2 rol3), user_id: user.id }
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
    describe 'token_payload' do
      let(:errors) { result['result.contract.params'].errors[:token_payload] }

      it 'is required' do
        token_params[:token_payload] = []

        expect(result).to be_failure
        expect(errors).to include 'must be filled'
      end

      pending 'roles into payload must exists in database'
    end
  end
end
