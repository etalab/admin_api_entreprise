require 'rails_helper'

RSpec.describe AuthorizationRequest do
  it 'has valid factory' do
    expect(build(:authorization_request)).to be_valid
  end

  describe 'destroy' do
    subject(:destroy) { authorization_request.destroy }

    context 'with an authorization request which is linked to multiple models' do
      let!(:authorization_request) { create(:authorization_request, :with_tokens, :validated, :with_all_contacts) }

      before do
        create(:magic_link, token: authorization_request.token)
      end

      it 'does not raise error due to db integrity checks' do
        expect { destroy }.not_to raise_error
      end
    end
  end

  describe 'organization association' do
    subject(:authorization_request) { create(:authorization_request) }

    let!(:organization) { create(:organization, siret: authorization_request.siret) }

    it 'has a valid association with organization' do
      expect(authorization_request.organization).to eq(organization)
    end
  end

  describe 'contacts associations' do
    let(:contact_technique) { create(:user, :contact_technique) }
    let(:contact_metier) { create(:user, :contact_metier) }
    let(:authorization_request) { create(:authorization_request, :with_contact_technique, :with_contact_metier) }

    it 'has valid association for contact technique and metier' do
      expect(authorization_request.contacts.count).to eq(2)

      expect(authorization_request.contact_technique).to be_present
      expect(authorization_request.contact_metier).to be_present
    end
  end

  describe '.with_tokens_for scope' do
    subject { described_class.with_tokens_for('particulier') }

    let!(:authorization_request) do
      create(:authorization_request, :with_tokens, api: 'particulier')
      create(:authorization_request, api: 'particulier')
      create(:authorization_request)
      create(:authorization_request)
    end

    it 'returns 1 token with api particulier' do
      expect(subject.count).to eq(1)
    end
  end

  describe '.viewable_by_users scope' do
    subject { described_class.viewable_by_users }

    let!(:viewable_authorization_requests) do
      [
        create(:authorization_request, :with_tokens, api: 'particulier', status: 'archived'),
        create(:authorization_request, api: 'particulier', status: 'revoked'),
        create(:authorization_request, status: 'validated'),
        create(:authorization_request, status: 'draft', validated_at: 1.month.ago)
      ]
    end

    let!(:not_viewable_authorization_request) do
      create(:authorization_request, status: 'draft')
    end

    it 'returns viewable authorization requests' do
      expect(subject).to include(*viewable_authorization_requests)
      expect(subject).not_to include(not_viewable_authorization_request)
    end
  end

  describe 'fetch token with the most recent expiration date' do
    let(:authorization_request) do
      create(:authorization_request, :with_multiple_tokens_one_valid)
    end

    it 'returns the tokens that expires the latest' do
      expect(authorization_request.most_recent_token).not_to eq(authorization_request.tokens.first.id)
    end
  end

  describe 'active_token associations' do
    let(:authorization_request) do
      create(:authorization_request, :with_multiple_tokens_one_valid)
    end

    it 'returns a token' do
      expect(authorization_request.token).to be_present
    end

    it 'returns an active token' do
      expect(authorization_request.active_token).to be_present
      expect(authorization_request.token.id).to eq(authorization_request.active_token.id)
    end
  end

  describe 'contacts' do
    let(:authorization_request) { create(:authorization_request, :with_contact_technique, :with_roles, roles: %i[demandeur contact_metier]) }

    it 'returns contacts' do
      expect(authorization_request.contacts).to include(authorization_request.contact_technique)
    end
  end

  describe 'contacts_no_demandeur' do
    let(:authorization_request) { create(:authorization_request, :with_contact_technique, :with_roles, roles: %i[demandeur contact_metier]) }

    it 'doesnt returns demandeur even if also contact' do
      expect(authorization_request.contacts_no_demandeur).not_to include(authorization_request.demandeur)
    end
  end

  describe '.prolong_token_expecting_updates' do
    subject { authorization_request.prolong_token_expecting_updates? }

    let!(:authorization_request) { create(:authorization_request) }

    context 'when there is no token' do
      it { is_expected.to be_falsey }
    end

    context 'when there is a token' do
      let!(:token) { create(:token, authorization_request:) }

      context 'when there is no last prolong token wizard' do
        it { is_expected.to be_falsey }
      end

      context 'when the last prolong token wizard requires update' do
        let!(:prolong_token_wizard) { create(:prolong_token_wizard, :requires_update, token:) }

        it { is_expected.to be_truthy }
      end

      context 'when the last prolong token wizard does not require update' do
        let(:last_prolong_token_wizard) { create(:prolong_token_wizard, token:, status: 'owner') }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe 'scopes' do
    let!(:authorization_request) { create(:authorization_request) }
    let!(:archived_authorization_request) { create(:authorization_request, status: 'archived', api: 'particulier') }

    describe '.archived' do
      subject { described_class.archived }

      it { is_expected.not_to include(*authorization_request) }
      it { is_expected.to include(*archived_authorization_request) }
    end

    describe '.not_archived' do
      subject { described_class.not_archived }

      it { is_expected.not_to include(*archived_authorization_request) }
      it { is_expected.to     include(*authorization_request) }
    end

    describe '.for_api' do
      subject { described_class.for_api('particulier') }

      it { is_expected.to include(*archived_authorization_request) }
    end
  end

  describe '#generate_oauth_credentials!' do
    subject(:authorization_request) { create(:authorization_request, intitule: 'Test Intitule') }

    it 'creates an oauth_application' do
      expect { authorization_request.generate_oauth_credentials! }
        .to change(OAuthApplication, :count).by(1)
    end

    it 'associates the oauth_application with the authorization_request' do
      oauth_app = authorization_request.generate_oauth_credentials!

      expect(authorization_request.reload.oauth_application).to eq(oauth_app)
      expect(oauth_app.owner).to eq(authorization_request)
    end

    it 'returns existing oauth_application if already present' do
      existing_app = authorization_request.generate_oauth_credentials!

      expect(authorization_request.generate_oauth_credentials!).to eq(existing_app)
      expect(OAuthApplication.count).to eq(1)
    end
  end

  describe '#oauth_scopes' do
    let(:authorization_request) { create(:authorization_request) }

    it 'returns empty array when no scopes' do
      expect(authorization_request.oauth_scopes).to eq([])
    end

    it 'returns scopes from authorization_request' do
      authorization_request.update!(scopes: %w[entreprises etablissements])

      expect(authorization_request.oauth_scopes).to eq(%w[entreprises etablissements])
    end
  end
end
