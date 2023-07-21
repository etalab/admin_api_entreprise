class ScheduleAuthorizationRequestMailjetEmailJob < ApplicationJob
  include MailjetHelpers

  queue_as :default

  attr_reader :authorization_request

  def perform(authorization_request_id, authorization_request_status, mailjet_attributes)
    @authorization_request = AuthorizationRequest.find_by(id: authorization_request_id)

    return if authorization_request.blank?
    return if authorization_request_status_changed?(authorization_request_status)

    deliver_mailjet_email(
      build_message(mailjet_attributes.stringify_keys)
    )
  rescue Mailjet::ApiError => e
    affect_mailjet_context_for_sentry(e)
    raise
  end

  private

  def build_message(mailjet_attributes)
    {
      from_name: 'API Entreprise',
      from_email: APIEntrepriseMailer.default_params[:from],
      to: build_recipient_attributes(mailjet_attributes['to']),
      cc: build_recipient_attributes(mailjet_attributes['cc']),
      vars: mailjet_attributes['vars'],
      'Mj-TemplateLanguage' => true,
      'Mj-TemplateID' => mailjet_attributes['template_id']
    }.compact
  end

  def build_recipient_attributes(recipient_payloads)
    return if recipient_payloads.nil?

    recipient_payloads.compact.map { |recipient_payload|
      recipient_payload.stringify_keys!

      "#{recipient_payload['full_name']} <#{recipient_payload['email']}>"
    }.join(', ')
  end

  def authorization_request_status_changed?(authorization_request_status)
    authorization_request.status != authorization_request_status &&
      new_status_nomenclature[authorization_request.status] != authorization_request_status
  end

  def new_status_nomenclature
    {
      'pending' => 'draft',
      'modification_pending' => 'changes_requested',
      'sent' => 'submitted',
      'validated' => 'validated',
      'refused' => 'refused'
    }.freeze
  end
end
