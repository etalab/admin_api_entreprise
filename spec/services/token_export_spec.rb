require 'csv'

RSpec.describe TokenExport, type: :service do
  describe 'Token export process' do
    let!(:user) { create(:user, :demandeur) }

    let!(:legacy_tokens) do
      {
        '1_scope' => {
          'token_id' => '22222222-2222-2222-2222-222222222220',
          'legacy_token_id' => '99999999-9999-9999-9999-999999999999',
          'scopes' => ['scope1']
        }
      }
    end

    let!(:authorization_request) do
      create(
        :authorization_request,
        :with_demandeur,
        demandeur: user,
        status: 'validated'
      )
    end

    before do
      allow(YAML).to receive(:load_file).and_return(legacy_tokens)
    end

    describe 'export nothing for a user without token' do
      subject(:token_export) { described_class.new(user).perform }

      let!(:token) do
        create(
          :token,
          id: '22222222-2222-2222-2222-222222222220',
          extra_info: { emails: ['watever'] },
          authorization_request:
        )
      end

      it 'returns a CSV' do
        expect(subject).to be_a(String)
        expect(CSV.parse(subject).size).to eq(1)
      end
    end

    describe 'should export tokens for a user' do
      subject(:token_export) { described_class.new(user).perform }

      let!(:token) do
        create(
          :token,
          id: '22222222-2222-2222-2222-222222222220',
          extra_info: { legacy_token_id: '99999999-9999-9999-9999-999999999999', emails: [user.email, 'watever.wherever@witness.forever'] },
          authorization_request:
        )
      end

      it 'returns a CSV' do
        expect(subject).to be_a(String)
        expect(CSV.parse(subject).size).to eq(2)
        expect(CSV.parse(subject).first).to eq(%w[siret intitule demandeur datapass_id nouveau_token ancien_token demarche])
        expect(CSV.parse(subject).last).to include(authorization_request.siret)
      end
    end
  end
end
