class APIParticulier::AuthorizationRequestMailerPreview < ActionMailer::Preview
  %w[
    demande_recue
    update_demande_recue
    reassurance_demande_recue
    update_reassurance_demande_recue

    embarquement_demande_refusee
    embarquement_modifications_demandees
    embarquement_relance_modifications_demandees
    update_embarquement_demande_refusee
    update_embarquement_modifications_demandees
    update_embarquement_relance_modifications_demandees

    embarquement_valide_to_demandeur_is_tech
    embarquement_valide_to_demandeur_seulement
    embarquement_valide_to_tech_cc_demandeur
    update_embarquement_valide_to_demandeur

    enquete_satisfaction
  ].each do |method|
    send('define_method', method) do
      APIParticulier::AuthorizationRequestMailer.send(method, { to:, cc:, authorization_request: })
    end
  end

  private

  def to
    'example@fake.com'
  end

  def cc; end

  def authorization_request
    AuthorizationRequest.where(api: 'particulier').first
  end
end
