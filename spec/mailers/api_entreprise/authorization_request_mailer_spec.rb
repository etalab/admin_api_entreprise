# frozen_string_literal: true

require 'rails_helper'

RSpec.describe APIEntreprise::AuthorizationRequestMailer do
  it_behaves_like 'an authorization request mailer',
    email_methods: %w[
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
    ],
    test_scopes: true,
    scope_test_method: 'embarquement_valide_to_demandeur_is_metier_not_tech',
    scope_label: I18n.t('api_entreprise.tokens.token.scope.entreprises.label')
end
