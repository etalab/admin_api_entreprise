require 'rails_helper'

RSpec.describe APIParticulier::TokenMailer do
  let(:authorization_request) { create(:authorization_request, :with_all_contacts, :with_tokens, api: 'particulier') }
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
    end
  end

  describe '#magic_link' do
    subject(:mailer) { described_class.magic_link(magic_link, host) }

    let(:magic_link) { create(:magic_link, email:) }
    let(:magic_link_url) { '' }
    let(:email) { 'muchemail@wow.com' }
    let(:host) { 'particulier.api.gouv.fr' }

    its(:subject) { is_expected.to eq('API Particulier - Lien d\'accès à votre jeton !') }
    its(:to) { is_expected.to contain_exactly(email) }

    it 'contains the magic link to the token' do
      expect(subject.html_part.decoded).to include(magic_link_url)
      expect(subject.text_part.decoded).to include(magic_link_url)
    end
  end
end
