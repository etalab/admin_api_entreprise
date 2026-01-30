RSpec.describe Editor do
  it 'has a valid factory' do
    expect(build(:editor)).to be_valid
  end

  describe 'authorization_requests association' do
    subject { editor.authorization_requests(api:) }

    let(:editor) { create(:editor, form_uids: %w[form1 form2]) }
    let(:api) { 'entreprise' }

    let!(:valid_authorization_requests) do
      [
        create(:authorization_request, api: 'entreprise', demarche: 'form1'),
        create(:authorization_request, api: 'entreprise', demarche: 'form2')
      ]
    end

    let!(:invalid_authorization_requests) do
      [
        create(:authorization_request, api: 'entreprise', demarche: 'wrong_form'),
        create(:authorization_request, api: 'particulier', demarche: 'form1')
      ]
    end

    it { is_expected.to match_array(valid_authorization_requests) }
    it { is_expected.to be_a(ActiveRecord::Relation) }
  end

  describe '#generate_oauth_credentials!' do
    subject(:editor) { create(:editor) }

    it 'creates an oauth_application' do
      expect { editor.generate_oauth_credentials! }
        .to change(OAuthApplication, :count).by(1)
    end

    it 'associates the oauth_application with the editor' do
      oauth_app = editor.generate_oauth_credentials!

      expect(editor.reload.oauth_application).to eq(oauth_app)
      expect(oauth_app.owner).to eq(editor)
    end

    it 'returns existing oauth_application if already present' do
      existing_app = editor.generate_oauth_credentials!

      expect(editor.generate_oauth_credentials!).to eq(existing_app)
      expect(OAuthApplication.count).to eq(1)
    end
  end

  describe '#can_access_authorization_request?' do
    let(:editor) { create(:editor) }
    let(:authorization_request) { create(:authorization_request) }

    it 'returns true when active delegation exists' do
      create(:editor_delegation, editor:, authorization_request:)

      expect(editor.can_access_authorization_request?(authorization_request)).to be true
    end

    it 'returns false when no delegation exists' do
      expect(editor.can_access_authorization_request?(authorization_request)).to be false
    end

    it 'returns false when delegation is revoked' do
      create(:editor_delegation, :revoked, editor:, authorization_request:)

      expect(editor.can_access_authorization_request?(authorization_request)).to be false
    end
  end
end
