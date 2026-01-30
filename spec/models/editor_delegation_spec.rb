RSpec.describe EditorDelegation do
  it 'has a valid factory' do
    expect(build(:editor_delegation)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:editor) }
    it { is_expected.to belong_to(:authorization_request) }
  end

  describe 'scopes' do
    let!(:active_delegation) { create(:editor_delegation) }
    let!(:revoked_delegation) { create(:editor_delegation, :revoked) }

    describe '.active' do
      it 'returns only active delegations' do
        expect(described_class.active).to contain_exactly(active_delegation)
      end
    end

    describe '.revoked' do
      it 'returns only revoked delegations' do
        expect(described_class.revoked).to contain_exactly(revoked_delegation)
      end
    end
  end

  describe '#revoke!' do
    subject(:delegation) { create(:editor_delegation) }

    it 'sets revoked_at timestamp' do
      delegation.revoke!

      expect(delegation.revoked_at).to be_present
      expect(delegation.revoked_at).to be_within(1.second).of(Time.current)
    end
  end

  describe '#revoked?' do
    it 'returns false when revoked_at is nil' do
      delegation = build(:editor_delegation, revoked_at: nil)

      expect(delegation).not_to be_revoked
    end

    it 'returns true when revoked_at is set' do
      delegation = build(:editor_delegation, revoked_at: Time.current)

      expect(delegation).to be_revoked
    end
  end

  describe '#active?' do
    it 'returns true when revoked_at is nil' do
      delegation = build(:editor_delegation, revoked_at: nil)

      expect(delegation).to be_active
    end

    it 'returns false when revoked_at is set' do
      delegation = build(:editor_delegation, revoked_at: Time.current)

      expect(delegation).not_to be_active
    end
  end
end
