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

    it 'is unique' do
      another_role = build(:role, name: role.name)
      another_role.valid?
      expect(another_role.errors[:name].size).to eq 1
    end
  end
end
