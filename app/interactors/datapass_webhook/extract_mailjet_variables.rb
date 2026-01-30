class DatapassWebhook::ExtractMailjetVariables < ApplicationInteractor
  def call
    context.mailjet_variables = build_common_mailjet_variables

    add_token_scopes if token_present?
  end

  private

  def build_common_mailjet_variables
    {
      'authorization_request_id' => authorization_request.external_id,
      'authorization_request_intitule' => authorization_request.intitule,
      'authorization_request_description' => authorization_request.description
    }.merge(
      build_contact_payload(:demandeur)
    ).merge(
      build_contact_payload(:contact_metier)
    ).merge(
      build_contact_payload(:contact_technique)
    )
  end

  def build_contact_payload(contact_kind)
    model = authorization_request.public_send(contact_kind)

    return {} if model.blank?

    {
      "#{contact_kind}_first_name" => model.first_name,
      "#{contact_kind}_last_name" => model.last_name,
      "#{contact_kind}_email" => model.email
    }
  end

  def event_from_instructor?
    events_from_instructor.include?(context.event)
  end

  def add_token_scopes
    token_roles.each do |role|
      context.mailjet_variables["token_role_#{role}"] = 'true'
    end
  end

  def token_present?
    authorization_request.scopes.present?
  end

  def token_roles
    @token_roles ||= authorization_request.scopes
  end

  def events_from_instructor
    %w[
      refuse_application
      review_application
      approve
      notify

      refuse
      request_changes
      validate
    ].freeze
  end

  def authorization_request
    context.authorization_request
  end
end
