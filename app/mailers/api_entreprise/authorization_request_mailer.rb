class APIEntreprise::AuthorizationRequestMailer < APIEntrepriseMailer
  def embarquement_brouillon_en_attente(to:, cc:, full_name:, authorization_request_external_id:)
    @full_name = full_name
    @authorization_request_external_id = authorization_request_external_id

    subject = "Votre demande d'accès à l'API Entreprise est en attente, voici quelques contenus pour vous aider à compléter votre demande."

    mail(to:, cc:, subject:) do |format|
      format.html
    end
  end
end
