class APIParticulier::AuthorizationRequestMailerPreview < ActionMailer::Preview
  %w[
    embarquement_brouillon_en_attente
    demande_recue
    reassurance_demande_recue

    embarquement_demande_refusee
    embarquement_modifications_demandees
    embarquement_relance_modifications_demandees

    embarquement_valide_to_demandeur_is_tech
    embarquement_valide_to_demandeur_seulement
    embarquement_valide_to_tech_cc_demandeur

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
