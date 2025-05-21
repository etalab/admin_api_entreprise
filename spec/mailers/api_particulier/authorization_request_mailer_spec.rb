# frozen_string_literal: true

require 'rails_helper'

RSpec.describe APIParticulier::AuthorizationRequestMailer do
  let(:authorization_request) { create(:authorization_request, :with_all_contacts) }
  let(:to) { 'anything@email.com' }
  let(:cc) { 'anything2@email.com' }

  %w[
    demande_recue
    update_demande_recue
    embarquement_demande_refusee
    embarquement_modifications_demandees
    update_embarquement_demande_refusee
    update_embarquement_modifications_demandees
    embarquement_valide_to_demandeur_is_tech
    embarquement_valide_to_demandeur_seulement
    embarquement_valide_to_tech_cc_demandeur
    update_embarquement_valide_to_demandeur
  ].each do |method|
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
end
