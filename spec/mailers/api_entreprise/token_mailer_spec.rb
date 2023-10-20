require 'rails_helper'

RSpec.describe APIEntreprise::TokenMailer do
  describe '#magic_link' do
    subject(:mailer) { described_class.magic_link(magic_link, host) }

    let(:magic_link) { create(:magic_link, email:) }
    let(:magic_link_url) { '' }
    let(:email) { 'muchemail@wow.com' }
    let(:host) { 'entreprise.api.gouv.fr' }

    its(:subject) { is_expected.to eq('API Entreprise - Lien d\'accès à votre jeton !') }
    its(:to) { is_expected.to contain_exactly(email) }

    it 'contains the magic link to the token' do
      expect(subject.html_part.decoded).to include(magic_link_url)
      expect(subject.text_part.decoded).to include(magic_link_url)
    end
  end
end
