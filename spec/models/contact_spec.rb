require 'rails_helper'

RSpec.describe Contact do
  it 'has valid factories' do
    expect(build(:contact)).to be_valid
  end

  describe '.not_expired scope' do
    subject { described_class.not_expired }

    let!(:valid_contact) { create(:contact, authorization_request: create(:authorization_request, tokens: [create(:token, blacklisted: false, archived: false)])) }
    let!(:invalid_contact) { create(:contact, authorization_request: create(:authorization_request, tokens: [create(:token, blacklisted: false, archived: true)])) }

    it 'renders valid content' do
      expect(subject.count).to eq(1)
      expect(subject).to include(valid_contact)
    end
  end

  describe '.with_tokens' do
    subject { described_class.with_tokens }

    let!(:contacts) do
      create(:authorization_request, :with_contacts, :with_tokens)
        .contacts
    end

    let!(:pending_contacts) do
      create(:authorization_request, :with_contacts)
        .contacts
    end

    it { is_expected.to include(*contacts) }
    it { is_expected.not_to include(*pending_contacts) }
  end

  describe 'validations' do
    describe '#email' do
      it { is_expected.to allow_value('valid@email.com').for(:email) }
      it { is_expected.not_to allow_value('not an email').for(:email) }
    end
  end

  describe 'valid_token associations' do
    let(:contact) do
      create(
        :contact,
        authorization_request: create(:authorization_request, :with_multiple_tokens_one_valid)
      )
    end

    it 'returns a token' do
      expect(contact.token).to be_present
    end

    it 'returns a valid token' do
      expect(contact.authorization_request.tokens.first.blacklisted?).to be true
      expect(contact.valid_token).to be_present
      expect(contact.token.id).to eq(contact.valid_token.id)
    end
  end
end
