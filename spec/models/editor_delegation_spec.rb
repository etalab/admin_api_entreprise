RSpec.describe EditorDelegation do
  describe 'associations' do
    it { is_expected.to belong_to(:editor) }
    it { is_expected.to belong_to(:authorization_request) }
  end

  describe 'scopes' do
    let!(:active_delegation) { create(:editor_delegation) }
    let!(:revoked_delegation) { create(:editor_delegation, revoked_at: Time.zone.now) }

    describe '.active' do
      it 'returns only delegations without revoked_at' do
        expect(described_class.active).to contain_exactly(active_delegation)
      end
    end

    describe '.revoked' do
      it 'returns only delegations with revoked_at' do
        expect(described_class.revoked).to contain_exactly(revoked_delegation)
      end
    end
  end
end
