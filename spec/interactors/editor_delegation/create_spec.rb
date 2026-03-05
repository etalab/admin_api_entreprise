RSpec.describe EditorDelegation::Create do
  subject(:result) { described_class.call(authorization_request:, editor_id:) }

  let(:authorization_request) { create(:authorization_request) }

  context 'with a delegable editor' do
    let(:editor) { create(:editor, :delegable) }
    let(:editor_id) { editor.id }

    it 'creates a delegation' do
      expect(result).to be_success
      expect(result.delegation).to be_persisted
      expect(result.delegation.editor).to eq(editor)
      expect(result.delegation.authorization_request).to eq(authorization_request)
    end
  end

  context 'with a non-delegable editor' do
    let(:editor) { create(:editor) }
    let(:editor_id) { editor.id }

    it 'fails' do
      expect(result).to be_failure
    end
  end

  context 'with a nonexistent editor' do
    let(:editor_id) { SecureRandom.uuid }

    it 'fails' do
      expect(result).to be_failure
    end
  end

  context 'when delegation already exists' do
    let(:editor) { create(:editor, :delegable) }
    let(:editor_id) { editor.id }

    before { create(:editor_delegation, editor:, authorization_request:) }

    it 'fails' do
      expect(result).to be_failure
    end
  end
end
