require 'rails_helper'

describe Token::Create do
  let(:token_payload) { { token_payload: ['rol1', 'rol2', 'rol3'] } }
  let(:user) { create :user }

  it 'persists valid' do
    result = described_class.(token_payload, user_id: user.id)
    expect(result).to be_success
    expect(result[:created_token]).to be_persisted
    expect(result[:created_token].user).to eq user
  end
end
