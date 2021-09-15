class DatapassWebhook::FindOrCreateAuthorizationRequest < ApplicationInteractor
  def call
    context.authorization_request = AuthorizationRequest.find_or_initialize_by(external_id: context.data['pass']['id'])
    context.authorization_request.assign_attributes(authorization_request_attributes)

    context.authorization_request.user = context.user
    create_or_update_contacts

    return if context.authorization_request.save

    fail!('Authorization request not valid', 'error', context.authorization_request.errors.to_h)
  end

  private

  def create_or_update_contacts
    create_or_update_contact(:responsable_technique, :technique)
    create_or_update_contact(:contact_metier, :metier)
  end

  def create_or_update_contact(from_kind, to_kind)
    contact = context.authorization_request.public_send("contact_#{to_kind}") || context.authorization_request.public_send("build_contact_#{to_kind}")
    contact_payload = contact_payload_for(from_kind)

    contact.assign_attributes(
      last_name: contact_payload['family_name'],
      first_name: contact_payload['given_name'],
      email: contact_payload['email'],
      phone_number: contact_payload['phone_number'],
    )

    contact.save
  end

  def authorization_request_attributes
    context.data['pass'].slice(
      'intitule',
      'description',
      'status',
    ).merge(authorization_request_attributes_for_current_event).merge(
      'last_update' => fired_at_as_datetime,
      'previous_external_id' => context.data['pass']['copied_from_enrollment_id'],
    )
  end

  def authorization_request_attributes_for_current_event
    case context.event
    when 'send_application'
      if context.authorization_request.first_submitted_at.nil?
        {
          'first_submitted_at' => fired_at_as_datetime,
        }
      else
        {}
      end
    when 'validate_application'
      {
        'validated_at' => fired_at_as_datetime,
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
    @fired_at_as_datetime ||= Time.at(context.fired_at).to_datetime
  end
end
