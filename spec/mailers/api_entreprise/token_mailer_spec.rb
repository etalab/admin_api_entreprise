require 'rails_helper'

RSpec.describe APIEntreprise::TokenMailer, type: :feature do
  let(:authorization_request) { create(:authorization_request, :with_all_contacts, :with_tokens) }
  let(:token) { authorization_request.token }

  %w[
    expiration_notice_90J
    expiration_notice_60J
    expiration_notice_30J
    expiration_notice_15J
    expiration_notice_7J
    expiration_notice_0J
  ].each do |method|
    describe "##{method}" do
      subject(:generate_email) { described_class.send(method, { token: }) }

      it 'generates an email' do
        expect { generate_email }.not_to raise_error
      end

      its(:to) { is_expected.to contain_exactly(authorization_request.demandeur.email) }

      it 'display demandeur full name' do
        expect(subject.html_part.decoded).to include(authorization_request.demandeur.full_name)
      end

      it 'has a link to datapass authorization_request copy' do
        expect(subject.html_part.decoded).to include(token_prolong_start_path(token_id: token.id))
      end
    end
  end

  describe '#magic_link' do
    subject(:mailer) { described_class.magic_link(magic_link, host) }

    let(:magic_link) { create(:magic_link, email:) }
    let(:magic_link_url) { '' }
    let(:email) { 'muchemail@wow.com' }
    let(:host) { 'entreprise.api.gouv.fr' }

    its(:subject) { is_expected.to eq("🔑 Lien d'accès temporaire au jeton API Entreprise") }
    its(:to) { is_expected.to contain_exactly(email) }

    it 'contains the magic link to the token' do
      expect(subject.html_part.decoded).to include(magic_link_url)
      expect(subject.text_part.decoded).to include(magic_link_url)
    end
  end
end
