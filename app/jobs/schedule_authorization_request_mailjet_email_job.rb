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
      messages: [
        message,
      ]
    )
  end

  def build_message(mailjet_attributes)
    {
      'From' => {
        'Email' => Rails.configuration.emails_sender_address,
      },
      'To' => build_recipient_attributes(mailjet_attributes['to']),
      'Cc' => build_recipient_attributes(mailjet_attributes['cc']),
      'Variables' => mailjet_attributes['vars'],
      'TemplateLanguage' => true,
      'TemplateID' => mailjet_attributes['template_id'],
    }.compact
  end

  def build_recipient_attributes(recipient_payloads)
    return if recipient_payloads.nil?

    recipient_payloads.map do |recipient_payload|
      recipient_payload.stringify_keys!

      {
        'Name' => recipient_payload['full_name'],
        'Email' => recipient_payload['email'],
      }
    end
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
