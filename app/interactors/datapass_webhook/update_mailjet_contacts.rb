class DatapassWebhook::UpdateMailjetContacts < ApplicationInteractor
  def call
    Mailjet::Contactslist_managemanycontacts.create(
      id: ::Rails.application.credentials.public_send("mj_list_id_#{authorization_request.api}!"),
      action: 'addnoforce',
      contacts: mailjet_contact_payloads
    )
  end

  private

  def mailjet_contact_payloads
    [
      mailjet_payload_for(:demandeur),
      mailjet_payload_for(:contact_metier),
      mailjet_payload_for(:contact_technique)
    ].compact.uniq do |mailjet_contact_payload|
      mailjet_contact_payload[:email]
    end
  end

  def mailjet_payload_for(kind) # rubocop:todo Metrics/AbcSize
    contact = authorization_request.send(kind)

    return if contact.nil?
    return if contact.email.nil?

    {
      email: contact.email,
      properties: {
        'prénom' => contact.first_name,
        'nom' => contact.last_name,
        'contact_demandeur' => contact.email == authorization_request.demandeur.try(:email),
        'contact_métier' => contact.email == authorization_request.contact_metier.try(:email),
        'contact_technique' => contact.email == authorization_request.contact_technique.try(:email)
      }
    }
  end

  def authorization_request
    context.authorization_request
  end
end
