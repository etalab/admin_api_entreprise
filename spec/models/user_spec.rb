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

    it 'is unique' do
      another_user = build(:user, email: user.email)
      another_user.valid?
      expect(another_user.errors['email'].size).to eq 1
    end
  end

  describe '#user_type' do
    it 'is required' do
      user.user_type = nil
      user.valid?
      expect(user.errors[:user_type].size).to be >= 1
    end

    it 'accepts "client" as value' do
      user.user_type = 'client'
      expect(user.valid?).to be true
    end

    it 'accepts "provider" as value' do
      user.user_type = 'provider'
      user.valid?
      expect(user.errors[:user_type].size).to eq 0
    end

    it 'does not accept another value' do
      user.user_type = "another value"
      user.valid?
      expect(user.errors[:user_type].size).to eq 1
    end
  end

  describe '#context' do
    context 'when #user_type is provider' do
      let(:user_provider) { create(:user_provider) }

      it 'is not required' do
        user_provider.context = ''
        expect(user_provider.valid?).to be true
      end

      it 'can be filled' do
        user_provider.context = "wow such context"
        expect(user_provider.valid?).to be true
      end
    end

    context 'when #user_type is client' do
      let(:user_client) { build(:user, user_type: 'client') }

      it 'is required' do
        user_client.context = ''
        user_client.valid?
        expect(user_client.errors[:context].size).to eq 1
      end
    end
  end

  describe '#contacts' do
    pending 'Email unique per contact types'
    pending 'Admin and tech contacts are required when #user_type is provider'
  end
end
