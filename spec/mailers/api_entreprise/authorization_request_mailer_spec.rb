require 'rails_helper'

RSpec.describe APIEntreprise::AuthorizationRequestMailer do
  let(:authorization_request) { create(:authorization_request, :with_all_contacts, :with_tokens) }
  let(:to) { 'anything@email.com' }
  let(:cc) { 'anything2@email.com' }

  let(:authorization_request_datapass_url) { "https://datapass-staging.api.gouv.fr/api-entreprise/#{authorization_request.external_id}" }
  let(:scope) { authorization_request.token.scopes.first }
  let(:scope_title) { I18n.t("api_entreprise.tokens.token.scope.#{scope}") }

  %w[
    embarquement_brouillon_en_attente
    demande_recue
    reassurance_demande_recue
    embarquement_modifications_demandees
    embarquement_relance_modifications_demandees
    embarquement_demande_refusee
  ].each do |method|
    describe "##{method}" do
      subject { described_class.send(method, { to:, cc:, authorization_request: }) }

      its(:body) { is_expected.to include(authorization_request_datapass_url) }
    end
  end

  %w[
    embarquement_brouillon_en_attente
    demande_recue
    reassurance_demande_recue
    embarquement_modifications_demandees
    embarquement_relance_modifications_demandees
    embarquement_demande_refusee
    embarquement_valide_to_editeur
    embarquement_valide_to_demandeur_is_tech_is_metier
    embarquement_valide_to_demandeur_seulement
    embarquement_valide_to_demandeur_is_metier_not_tech
    enquete_satisfaction
    embarquement_valide_to_demandeur_is_tech_not_metier
  ].each do |method|
    describe "##{method}" do
      subject { described_class.send(method, { to:, cc:, authorization_request: }) }

      its(:body) { is_expected.to include(authorization_request.demandeur.full_name) }
    end
  end

  %w[
    embarquement_valide_to_editeur
    embarquement_valide_to_demandeur_is_tech_is_metier
    embarquement_valide_to_demandeur_seulement
    embarquement_valide_to_metier_cc_demandeur_tech
    embarquement_valide_to_demandeur_is_metier_not_tech
    embarquement_valide_to_tech_cc_demandeur_metier
    embarquement_valide_to_demandeur_is_tech_not_metier
  ].each do |method|
    describe "##{method}" do
      subject { described_class.send(method, { to:, cc:, authorization_request: }) }

      its(:body) { is_expected.to include(scope_title) }
    end
  end

  %w[
    embarquement_valide_to_tech_cc_demandeur_metier
  ].each do |method|
    describe "##{method}" do
      subject { described_class.send(method, { to:, cc:, authorization_request: }) }

      its(:body) { is_expected.to include(authorization_request.contact_technique.full_name) }
    end
  end

  %w[
    enquete_satisfaction
  ].each do |method|
    describe "##{method}" do
      subject { described_class.send(method, { to:, cc:, authorization_request: }) }

      its(:body) { is_expected.to include(authorization_request.intitule) }
    end
  end
end
