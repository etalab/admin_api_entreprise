require 'rails_helper'

RSpec.describe AuthorizationRequest do
  it 'has valid factory' do
    expect(build(:authorization_request)).to be_valid
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
      expect(authorization_request.tokens.first.id).not_to eq(authorization_request.active_token.id)
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
end
