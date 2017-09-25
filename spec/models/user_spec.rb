require 'rails_helper'

describe User, type: :model do
  let(:user) { create(:user) }

  it 'is valid' do
    expect(user).to be_valid
    expect(user).to be_persisted
  end

  describe '#email' do
    it 'is required' do
      user.email = ''
      user.valid?
      expect(user.errors[:email].size).to eq 2
    end

    it 'has a valid format' do
      user.email = 'not.an.email'
      user.valid?
      expect(user.errors[:email].size).to eq 1
    end
  end
end
