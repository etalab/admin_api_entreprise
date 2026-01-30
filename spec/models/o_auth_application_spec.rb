RSpec.describe OAuthApplication do
  it 'has a valid factory' do
    expect(build(:oauth_application)).to be_valid
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it 'validates uid uniqueness' do
      existing = create(:oauth_application)
      duplicate = build(:oauth_application, uid: existing.uid)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:uid]).to be_present
    end
  end

  describe 'credential generation' do
    subject(:oauth_application) { build(:oauth_application) }

    it 'generates uid before validation' do
      oauth_application.valid?

      expect(oauth_application.uid).to be_present
      expect(oauth_application.uid.length).to eq(64)
    end

    it 'generates secret before validation' do
      oauth_application.valid?

      expect(oauth_application.secret).to be_present
      expect(oauth_application.secret.length).to eq(128)
    end

    it 'does not override existing credentials' do
      oauth_application.uid = 'custom_uid'
      oauth_application.secret = 'custom_secret'
      oauth_application.valid?

      expect(oauth_application.uid).to eq('custom_uid')
      expect(oauth_application.secret).to eq('custom_secret')
    end
  end

  describe 'polymorphic owner' do
    it 'can belong to an editor' do
      editor = create(:editor)
      oauth_application = create(:oauth_application, owner: editor)

      expect(oauth_application.owner).to eq(editor)
      expect(oauth_application.owner_type).to eq('Editor')
    end

    it 'can belong to an authorization_request' do
      authorization_request = create(:authorization_request)
      oauth_application = create(:oauth_application, owner: authorization_request)

      expect(oauth_application.owner).to eq(authorization_request)
      expect(oauth_application.owner_type).to eq('AuthorizationRequest')
    end
  end
end
