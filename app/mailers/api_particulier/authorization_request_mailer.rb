class APIParticulier::AuthorizationRequestMailer < APIParticulierMailer
  include ExternalUrlHelper

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
    send('define_method', method) do |args|
      @all_scopes = I18n.t('api_particulier.tokens.token.scope')
      @authorization_request = args[:authorization_request]
      @authorization_request_scopes = @authorization_request.token.scopes.map(&:to_sym) if @authorization_request.token.present?
      @authorization_request_datapass_url = datapass_authorization_request_url(@authorization_request)

      @full_name_demandeur = @authorization_request.demandeur.full_name
      @full_name_contact_technique = @authorization_request.contact_technique&.full_name

      mail(to: extract_recipients(args[:to]), cc: extract_recipients(args[:cc]), subject: t('.subject')) { |format| format.html }
    end
  end

  private

  def extract_recipients(recipients)
    return if recipients.blank?

    Array(recipients).map do |recipient|
      if recipient.is_a?(Hash)
        recipient[:email] || recipient['email']
      else
        recipient
      end
    end
  end
end
