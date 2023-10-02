require 'csv'

RSpec.describe TokenExport, type: :service do
  describe 'Token export process' do
    subject(:token_export) { described_class.new('watever').perform }

    let!(:user) { create(:user, :demandeur) }
    let!(:token) do
      create(
        :token,
        id: '12131415-1111-1111-1111-111111111110',
        extra_info: { legacy_token_id: '11111111-1111-1111-1111-111111111111' },
        authorization_request:
      )
    end
    let!(:legacy_tokens) do
      {
        '1_scope' => {
          'token_id' => '12131415-1111-1111-1111-111111111110',
          'legacy_token_id' => '11111111-1111-1111-1111-111111111111',
          'scopes' => ['scope1']
        }
      }
    end

    before do
      allow(CSV).to receive(:open).and_return(true)
      allow(YAML).to receive(:load_file).and_return(legacy_tokens)
    end

    describe 'export token for a demandeur' do
      let!(:authorization_request) do
        create(
          :authorization_request,
          status: 'validated',
          demandeur_authorization_request_role: user.user_authorization_request_roles.first
        )
      end

      it 'has a demandeur key' do
        expect(subject["demandeur_#{user.email}"]).not_to be_nil
      end
    end

    describe 'export token for a contact_technique' do
      let!(:user_tech) { create(:user, :contact_technique) }

      let!(:authorization_request) do
        create(
          :authorization_request, status: 'validated',
          demandeur_authorization_request_role: user.user_authorization_request_roles.first,
          contact_technique_authorization_request_role: user_tech.user_authorization_request_roles.first
        )
      end

      it 'has a contact key' do
        expect(subject["contact_technique_#{user_tech.email}"]).not_to be_nil
      end
    end

    describe 'export token for a demarche' do
      let!(:authorization_request) do
        create(:authorization_request, status: 'validated', demandeur_authorization_request_role: user.user_authorization_request_roles.first, demarche: 1234)
      end

      it 'has a demarche key' do
        expect(subject["demarche_#{authorization_request.demarche}"]).not_to be_nil
      end
    end
  end
end
