require 'rails_helper'

RSpec.describe APIEntreprise::AuthorizationRequestMailer do
  let(:authorization_request) { create(:authorization_request, :with_all_contacts, :with_tokens) }
  let(:to) { 'anything@email.com' }
  let(:cc) { 'anything2@email.com' }

  %w[
    enquete_satisfaction
    embarquement_brouillon_en_attente
    embarquement_demande_refusee
    embarquement_modifications_demandees
    embarquement_relance_modifications_demandees
    embarquement_valide_to_editeur
    embarquement_valide_to_demandeur_is_tech_is_metier
    embarquement_valide_to_demandeur_seulement
    embarquement_valide_to_metier_cc_demandeur_tech
    embarquement_valide_to_demandeur_is_metier_not_tech
    embarquement_valide_to_demandeur_is_tech_not_metier
    embarquement_valide_to_tech_cc_demandeur_metier
    demande_recue
    reassurance_demande_recue
  ].each do |method|
    describe "##{method}" do
      subject(:generate_email) { described_class.send(method, { to:, cc:, authorization_request: }) }

      it 'generates an email' do
        expect { generate_email }.not_to raise_error
      end

      it 'display authorization_request external id' do
        expect(subject.html_part.decoded).to include(authorization_request.external_id) unless method == 'enquete_satisfaction'
      end
    end
  end
end
