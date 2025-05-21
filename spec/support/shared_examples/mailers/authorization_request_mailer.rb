require 'rails_helper'

RSpec.shared_examples 'an authorization request mailer' do |options = {}|
  let(:authorization_request) { create(:authorization_request, :with_all_contacts) }
  let(:to) { 'anything@email.com' }
  let(:cc) { 'anything2@email.com' }

  # Use the email methods provided in options or use an empty array as fallback
  # This allows API-specific email method lists
  email_methods = options[:email_methods] || []

  email_methods.each do |method|
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

  # Only include the scopes test if specified in options
  if options[:test_scopes]
    let(:scope_label) { options[:scope_label] }

    describe 'scopes in mails' do
      subject(:generate_email) { described_class.send(options[:scope_test_method], { to:, cc:, authorization_request: }) }

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
