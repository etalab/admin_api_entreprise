RSpec.describe EditorDelegation::Revoke do
  subject(:result) { described_class.call(authorization_request:, delegation_id:) }

  let(:authorization_request) { create(:authorization_request) }

  context 'with an active delegation' do
    let(:delegation) { create(:editor_delegation, authorization_request:) }
    let(:delegation_id) { delegation.id }

    it 'revokes the delegation' do
      expect(result).to be_success
      expect(delegation.reload.revoked_at).to be_present
    end
  end

  context 'with a nonexistent delegation' do
    let(:delegation_id) { SecureRandom.uuid }

    it 'fails' do
      expect(result).to be_failure
    end
  end

  context 'with a delegation from another authorization request' do
    let(:other_ar) { create(:authorization_request) }
    let(:delegation) { create(:editor_delegation, authorization_request: other_ar) }
    let(:delegation_id) { delegation.id }

    it 'fails' do
      expect(result).to be_failure
    end
  end
end
