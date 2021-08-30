class ScheduleAuthorizationRequestMailjetEmailJob < ApplicationJob
  attr_reader :authorization_request

  def perform(authorization_request_id, authorization_request_status, mailjet_attributes)
    @authorization_request = AuthorizationRequest.find_by(id: authorization_request_id)

    return if authorization_request.blank?
    return if authorization_request.status != authorization_request_status

    deliver_mailjet_email(
      build_message(mailjet_attributes.stringify_keys)
    )
  rescue Mailjet::ApiError => e
    set_mailjet_context_for_sentry(e)
    raise
  end

  def deliver_mailjet_email(message)
    Mailjet::Send.create(
      message,
    )
  end

  def build_message(mailjet_attributes)
    {
      from_name: 'API Entreprise',
      from_email: Rails.configuration.emails_sender_address,
      to: build_recipient_attributes(mailjet_attributes['to']),
      cc: build_recipient_attributes(mailjet_attributes['cc']),
      vars: mailjet_attributes['vars'],
      'Mj-TemplateLanguage' => true,
      'Mj-TemplateID' => mailjet_attributes['template_id'],
    }.compact
  end

  def build_recipient_attributes(recipient_payloads)
    return if recipient_payloads.nil?

    recipient_payloads.map do |recipient_payload|
      recipient_payload.stringify_keys!

      "#{recipient_payload['full_name']} <#{recipient_payload['email']}>"
    end.join(', ')
  end

  def set_mailjet_context_for_sentry(mailjet_exception)
    Sentry.set_context(
      'mailjet error',
      build_mailjet_error_context(mailjet_exception)
    )
  end

  def build_mailjet_error_context(mailjet_exception)
    {
      mailjet_error_code: mailjet_exception.code,
      mailjet_error_reason: mailjet_exception.reason,
    }
  end
end
