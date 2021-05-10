require 'rails_helper'

RSpec.describe(AccessToken) do
  context 'token encoding' do
    payload = { data: 'test', more_data: 'verytest' }
    token = described_class.create(payload)

    it 'returns a token from a hash payload' do
      expect(token).to(be_a(String))
    end

    it 'decodes a valid token' do
      expect(described_class.decode(token)).to(include(payload))
    end

    it 'raises error on invalid token' do
      expect { described_class.decode(token + 'a') }
        .to(raise_error(JWT::VerificationError))
    end
  end
end
