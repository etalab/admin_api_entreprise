module MailjetHelpers
  def deliver_mailjet_email(message)
    Mailjet::Send.create(
      sanitize_message_payload(message)
    )
  end

  def affect_mailjet_context_for_sentry(mailjet_exception)
    Sentry.set_context(
      'mailjet error',
      build_mailjet_error_context(mailjet_exception)
    )
  end

  def build_mailjet_error_context(mailjet_exception)
    {
      mailjet_error_code: mailjet_exception.code,
      mailjet_error_reason: mailjet_exception.reason
    }
  end

  private

  def sanitize_message_payload(message)
    message.stringify_keys!

    message['vars'] = replace_nil_values_with_empty_string(message['vars'])

    message
  end

  def replace_nil_values_with_empty_string(vars)
    return if vars.nil?

    vars.transform_values do |value|
      value.nil? ? '' : value
    end
  end
end
