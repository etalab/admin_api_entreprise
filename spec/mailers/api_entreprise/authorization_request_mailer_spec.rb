require 'rails_helper'

RSpec.describe APIEntreprise::AuthorizationRequestMailer do
  let(:authorization_request) { create(:authorization_request, :with_all_contacts) }
  let(:to) { 'anything@email.com' }
  let(:cc) { 'anything2@email.com' }

  %w[
    enquete_satisfaction
    embarquement_demande_refusee
    update_embarquement_demande_refusee
    embarquement_modifications_demandees
    update_embarquement_modifications_demandees
    embarquement_valide_to_editeur
    embarquement_valide_to_demandeur_is_tech_is_metier
    embarquement_valide_to_demandeur_seulement
    embarquement_valide_to_metier_cc_demandeur_tech
    embarquement_valide_to_demandeur_is_metier_not_tech
    embarquement_valide_to_demandeur_is_tech_not_metier
    embarquement_valide_to_tech_cc_demandeur_metier
    update_embarquement_valide_to_demandeur
    demande_recue
    update_demande_recue
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

  describe 'scopes in mails' do
    subject(:generate_email) { described_class.embarquement_valide_to_demandeur_is_metier_not_tech({ to:, cc:, authorization_request: }) }

    let(:scope_label) { I18n.t('api_entreprise.tokens.token.scope.entreprises.label') }

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
