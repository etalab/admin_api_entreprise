require 'rails_helper'

RSpec.describe AuthorizationRequest do
  it 'has valid factory' do
    expect(build(:authorization_request)).to be_valid
  end

  describe 'contacts associations' do
    let(:authorization_request) { create(:authorization_request, :with_contacts) }

    it 'has valid association for contact technique and metier' do
      expect(authorization_request.contacts.count).to eq(2)

      expect(authorization_request.contact_technique).to be_present
      expect(authorization_request.contact_metier).to be_present
    end
  end

  describe 'valid_token associations' do
    let(:authorization_request) do
      create(:authorization_request, :with_multiple_tokens_one_valid)
    end

    it 'returns a token' do
      expect(authorization_request.token).to be_present
    end

    it 'returns a valid token' do
      expect(authorization_request.valid_token).to be_present
      expect(authorization_request.token.id).to eq(authorization_request.valid_token.id)
      expect(authorization_request.tokens.first.id).not_to eq(authorization_request.valid_token.id)
    end
  end
end
