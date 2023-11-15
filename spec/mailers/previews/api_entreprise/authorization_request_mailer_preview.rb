class APIEntreprise::AuthorizationRequestMailerPreview < ActionMailer::Preview
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
    send('define_method', method) do
      APIEntreprise::AuthorizationRequestMailer.send(method, { to:, cc:, authorization_request: })
    end
  end

  private

  def to
    'example@fake.com'
  end

  def cc; end

  def authorization_request
    AuthorizationRequest.with_tokens_for('entreprise').first
  end
end
