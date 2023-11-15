require 'rails_helper'

RSpec.describe APIEntreprise::TokenMailer do
  let(:authorization_request) { create(:authorization_request, :with_all_contacts, :with_tokens) }
  let(:to) { 'anything@email.com' }
  let(:cc) { 'anything2@email.com' }

  %w[
    expiration_notice_J-90
    expiration_notice_J-60
    expiration_notice_J-30
    expiration_notice_J-15
    expiration_notice_J-7
    expiration_notice_J-0_expired
  ].each do |method|
    describe "##{method}" do
      subject(:generate_email) { described_class.send(method, { to:, cc:, authorization_request: }) }

      it 'generates an email' do
        expect { generate_email }.not_to raise_error
      end
    end
  end

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
