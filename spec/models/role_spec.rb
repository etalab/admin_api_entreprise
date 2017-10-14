require 'rails_helper'

describe Role, type: :model do
  let(:role) { create(:role) }

  context 'when model fields are valid' do
    subject { role }

    it { is_expected.to be_valid }
    it { is_expected.to be_persisted }
  end

  describe '#name' do
    it 'is required' do
      role.name = nil
      role.valid?
      expect(role.errors[:name].size).to eq 1
    end

    it 'is max 50 characters long' do
      role.name = 'a' * 51
      role.valid?
      expect(role.errors[:name].size).to eq 1
    end

    it 'is unique' do
      another_role = build(:role, name: role.name)
      another_role.valid?
      expect(another_role.errors[:name].size).to eq 1
    end
  end

  describe '#code' do
    it 'is required' do
      role.code = ''
      role.valid?
      expect(role.errors[:code].size).to eq 1
    end

    it 'is max 4 characters long' do
      role.code = 'a' * 5
      role.valid?
      expect(role.errors[:code].size).to eq 1
    end

    it 'is unique' do
      another_role = build(:role, code: role.code)
      another_role.valid?
      expect(another_role.errors[:code].size).to eq 1
    end
  end
end
