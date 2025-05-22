# frozen_string_literal: true

require 'rails_helper'

RSpec.describe APIParticulier::AuthorizationRequestMailer do
  it_behaves_like 'an authorization request mailer',
    email_methods: %w[
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
    ]
end
