class APIEntreprise::AuthorizationRequestMailer < APIEntrepriseMailer
  include ExternalUrlHelper

  %w[
    enquete_satisfaction
    embarquement_brouillon_en_attente
    embarquement_demande_refusee
    embarquement_modifications_demandees
    embarquement_relance_modifications_demandees
    embarquement_valide_to_editeur
    embarquement_valide_to_demandeur_tech_metier
    embarquement_valide_to_demandeur_seulement
    embarquement_valide_to_metier_cc_demandeur_tech
    embarquement_valide_to_demandeur_not_tech
    embarquement_valide_to_demandeur_tech_not_metier
    embarquement_valide_to_tech_cc_demandeur_metier
    embarquement_valide_to_tech_cc_metier
    demande_recue
    reassurance_demande_recue
  ].each do |method|
    send('define_method', method) do |args|
      @all_scopes = I18n.t('api_entreprise.tokens.token.scope')
      @authorization_request = args[:authorization_request]
      @authorization_request_scopes = @authorization_request.token.scopes.map(&:to_sym)
      @authorization_request_datapass_url = datapass_authorization_request_url(@authorization_request)

      @full_name_demandeur = @authorization_request.demandeur.full_name
      @full_name_contact_technique = @authorization_request.contact_technique&.full_name
      @full_name_contact_metier = @authorization_request.contact_metier&.full_name

      mail(to: args[:to], cc: args[:cc], subject: t('.subject')) { |format| format.html }
    end
  end
end
