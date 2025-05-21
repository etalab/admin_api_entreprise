# frozen_string_literal: true

RSpec.shared_examples 'an authorization request mailer' do |methods_array, scope_label = nil|
  let(:authorization_request) { create(:authorization_request, :with_all_contacts) }
  let(:to) { 'anything@email.com' }
  let(:cc) { 'anything2@email.com' }

  methods_array.each do |method|
    describe "##{method}" do
      subject(:generate_email) { described_class.send(method, { to:, cc:, authorization_request: }) }

      it 'generates an email' do
        expect { generate_email }.not_to raise_error
      end

      it 'display authorization_request external id' do
        expect(subject.html_part.decoded).to include(authorization_request.external_id)
      end
    end
  end

  if scope_label.present?
    describe 'scopes in mails' do
      subject(:generate_email) { described_class.embarquement_valide_to_demandeur_is_metier_not_tech({ to:, cc:, authorization_request: }) }

      describe 'when there is no token' do
        it 'doesnt display scopes' do
          expect(subject.html_part.decoded).not_to include('Cette habilitation donne accès aux API suivantes')
          expect(subject.html_part.decoded).not_to include(scope_label)
        end
      end

      describe 'when there is a token' do
        let(:authorization_request) { create(:authorization_request, :with_all_contacts, :with_tokens) }

        it 'display scopes' do
          expect(subject.html_part.decoded).to include('Cette habilitation donne accès aux API suivantes')
          expect(subject.html_part.decoded).to include(scope_label)
        end
      end
    end
  end
end
