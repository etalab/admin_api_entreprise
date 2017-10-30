require 'rails_helper'

describe Token, type: :model do
  let(:token) { create(:token) }

  context 'when attributes are valid ' do
    subject { token }

    it { is_expected.to be_valid }
    it { is_expected.to be_persisted }
  end

  describe '#value' do
    it 'is required' do
      token.value = ''
      token.valid?
      expect(token.errors[:value].size).to be >= 1
    end

    it 'has a JWT format' do
      token.value = 'not a JWT string format'
      token.valid?
      expect(token.errors[:value].size).to eq 1
    end
  end
end
