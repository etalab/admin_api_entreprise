RSpec.describe MigrateLegacyTokenService do
  subject { described_class.new(tokens).perform }

  let!(:legacy_token) { create(:token, :legacy_token) }
  let!(:non_legacy_token) { create(:token) }
  let!(:migrated_legacy_token) { create(:token, :legacy_token, :legacy_token_migrated) }

  let!(:tokens) do
    [
      legacy_token,
      non_legacy_token,
      migrated_legacy_token
    ]
  end

  describe '#migrate_legacy_token' do
    it 'migrates legacy tokens' do
      expect { subject }.to change { legacy_token.reload.legacy_token_migrated? }.from(false).to(true)
    end

    it 'does not migrate non legacy tokens' do
      expect { subject }.not_to change { non_legacy_token.reload.legacy_token_migrated? }
    end

    it 'does not migrate already migrated tokens' do
      expect { subject }.not_to change { migrated_legacy_token.reload.legacy_token_migrated? }
    end
  end
end
