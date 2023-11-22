# TODO: can be factorized better with previous interactor
class DatapassWebhook::FindOrCreateAuthorizationRequest < ApplicationInteractor
  def call # rubocop:disable Metrics/AbcSize
    context.authorization_request = AuthorizationRequest.find_or_initialize_by(external_id: context.data['pass']['id'])
    context.authorization_request.assign_attributes(authorization_request_attributes)

    create_or_update_contacts_with_roles

    return if context.authorization_request.save

    fail!('Authorization request not valid', 'error', context.authorization_request.errors.to_hash)
  end

  private

  def create_or_update_contacts_with_roles
    {
      'demandeur' => 'demandeur',
      'contact_metier' => 'contact_metier',
      'responsable_technique' => 'contact_technique'
    }.each do |contact_kind, role|
      contact_payload = contact_payload_for(contact_kind)

      next if contact_payload.blank?

      user = extract_user_from_contact_payload(contact_payload)

      next unless user.valid?

      user_authorization_request_role = context.authorization_request.user_authorization_request_roles.find_or_initialize_by(role:)
      user_authorization_request_role.update!(user:) if user_authorization_request_role.user != user
    end
  end

  def extract_user_from_contact_payload(contact_payload)
    user = User.find_or_initialize_by_email(contact_payload['email'])

    user.assign_attributes(
      last_name: contact_payload['family_name'],
      first_name: contact_payload['given_name']
    )

    user
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
    authorization_request_attributes_for_current_event = {}

    authorization_request_attributes_for_current_event['first_submitted_at'] = fired_at_as_datetime if context.event != 'draft' && context.authorization_request.first_submitted_at.nil?

    authorization_request_attributes_for_current_event['validated_at'] = fired_at_as_datetime if %w[validate_application validate].include?(context.event)

    authorization_request_attributes_for_current_event
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
