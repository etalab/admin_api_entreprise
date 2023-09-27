class APIEntreprise::AuthorizationRequestMailer < APIEntrepriseMailer
  def embarquement_brouillon_en_attente(to:, cc:, full_name:, authorization_request_external_id:)
    @full_name = full_name
    @authorization_request_external_id = authorization_request_external_id

    mail(to:, cc:) do |format|
      format.html
    end
  end
end
