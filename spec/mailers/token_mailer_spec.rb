require 'rails_helper'

RSpec.describe TokenMailer do
  describe '#magic_link' do
    subject(:mailer) { described_class.magic_link(email, token) }

    let(:email) { 'muchemail@wow.com' }
    let(:token) { create(:token, :with_magic_link) }

    its(:subject) { is_expected.to eq('API Entreprise - Lien d\'accès à votre jeton !') }
    its(:from) { is_expected.to include(Rails.configuration.emails_sender_address) }
    its(:to) { is_expected.to contain_exactly(email) }

    it 'contains the magic link to the token' do
      magic_link_url = Rails.configuration.token_magic_link_url + token.magic_link_token

      expect(subject.html_part.decoded).to include(magic_link_url)
      expect(subject.text_part.decoded).to include(magic_link_url)
    end
  end
end
