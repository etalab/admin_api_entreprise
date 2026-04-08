RSpec.describe EditorToken do
  it 'has a valid factory' do
    expect(build(:editor_token)).to be_valid
  end

  describe 'associations' do
    it { is_expected.to belong_to(:editor) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:exp) }
  end

  describe '#rehash' do
    subject { editor_token.rehash }

    let(:editor_token) { create(:editor_token) }

    it 'returns a JWT string' do
      expect(subject).to be_a(String)
    end

    it 'contains editor: true in payload' do
      payload = AccessToken.decode(subject)

      expect(payload[:editor]).to be true
    end

    it 'contains expected fields' do
      payload = AccessToken.decode(subject)

      expect(payload[:uid]).to eq(editor_token.id)
      expect(payload[:jti]).to eq(editor_token.id)
      expect(payload[:sub]).to eq(editor_token.editor.name)
      expect(payload[:version]).to eq('1.0')
      expect(payload[:iat]).to eq(editor_token.iat)
      expect(payload[:exp]).to eq(editor_token.exp)
    end
  end

  describe '#expired?' do
    it 'returns true when exp is in the past' do
      editor_token = build(:editor_token, :expired)

      expect(editor_token).to be_expired
    end

    it 'returns false when exp is in the future' do
      editor_token = build(:editor_token)

      expect(editor_token).not_to be_expired
    end
  end

  describe '#blacklisted?' do
    it 'returns true when blacklisted_at is in the past' do
      editor_token = build(:editor_token, :blacklisted)

      expect(editor_token).to be_blacklisted
    end

    it 'returns false when blacklisted_at is nil' do
      editor_token = build(:editor_token)

      expect(editor_token).not_to be_blacklisted
    end

    it 'returns false when blacklisted_at is in the future' do
      editor_token = build(:editor_token, blacklisted_at: 1.month.from_now)

      expect(editor_token).not_to be_blacklisted
    end
  end

  describe '#active?' do
    it 'returns true when not expired and not blacklisted' do
      editor_token = build(:editor_token)

      expect(editor_token).to be_active
    end

    it 'returns false when expired' do
      editor_token = build(:editor_token, :expired)

      expect(editor_token).not_to be_active
    end

    it 'returns false when blacklisted' do
      editor_token = build(:editor_token, :blacklisted)

      expect(editor_token).not_to be_active
    end
  end

  describe '.active' do
    let!(:active_token) { create(:editor_token) }
    let!(:expired_token) { create(:editor_token, :expired) }
    let!(:blacklisted_token) { create(:editor_token, :blacklisted) }

    it 'returns only active tokens' do
      expect(described_class.active).to contain_exactly(active_token)
    end
  end
end
