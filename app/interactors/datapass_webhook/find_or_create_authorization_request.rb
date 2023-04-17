# TODO: can be factorized better with previous interactor
class DatapassWebhook::FindOrCreateAuthorizationRequest < ApplicationInteractor
  def call # rubocop:disable Metrics/AbcSize
    context.authorization_request = AuthorizationRequest.find_or_initialize_by(external_id: context.data['pass']['id'])
    context.authorization_request.assign_attributes(authorization_request_attributes)

    create_or_update_demandeur_role
    create_or_update_contacts_with_roles

    return if context.authorization_request.save

    fail!('Authorization request not valid', 'error', context.authorization_request.errors.to_hash)
  end

  private

  def create_or_update_demandeur_role
    UserAuthorizationRequestRole
      .find_or_create_by(user: context.authorization_request.demandeur || context.user, authorization_request: context.authorization_request, role: 'demandeur')
      .update!(user: context.user)
  end

  def create_or_update_contacts_with_roles
    create_contact_metier_with_role
    create_contact_technique_with_role
  end

  def create_contact_metier_with_role
    contact_payload = contact_payload_for(:contact_metier)

    return if contact_payload.blank?

    contact = create_or_update_contact_from_payload(contact_payload, :contact_metier)

    UserAuthorizationRequestRole.create(user_id: contact.id, authorization_request: context.authorization_request, role: 'contact_metier')
  end

  def create_contact_technique_with_role
    contact_payload = contact_payload_for(:responsable_technique)

    return if contact_payload.blank?

    contact = create_or_update_contact_from_payload(contact_payload, :contact_technique)

    UserAuthorizationRequestRole.create(user_id: contact.id, authorization_request: context.authorization_request, role: 'contact_technique')
  end

  def create_or_update_contact_from_payload(contact_payload, contact_kind)
    contact = context.authorization_request.public_send(contact_kind) || User.create

    contact.assign_attributes(
      last_name: contact_payload['family_name'],
      first_name: contact_payload['given_name'],
      email: contact_payload['email'],
      phone_number: contact_payload['phone_number']
    )

    contact.save
    contact
  end

  def authorization_request_attributes
    context.data['pass'].slice(
      'intitule',
      'description',
      'demarche',
      'status',
      'siret'
    ).merge(authorization_request_attributes_for_current_event).merge(
      'last_update' => fired_at_as_datetime,
      'previous_external_id' => context.data['pass']['copied_from_enrollment_id'],
      'api' => context.api
    )
  end

  def authorization_request_attributes_for_current_event
    case context.event
    when 'send_application', 'submit'
      if context.authorization_request.first_submitted_at.nil?
        {
          'first_submitted_at' => fired_at_as_datetime
        }
      else
        {}
      end
    when 'validate_application', 'validate'
      {
        'validated_at' => fired_at_as_datetime
      }
    else
      {}
    end
  end

  def contact_payload_for(kind)
    context.data['pass']['team_members'].find do |contact_payload|
      contact_payload['type'] == kind.to_s
    end
  end

  def fired_at_as_datetime
    @fired_at_as_datetime ||= Time.zone.at(context.fired_at).to_datetime
  end
end
