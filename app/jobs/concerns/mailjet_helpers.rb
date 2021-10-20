module MailjetHelpers
  def deliver_mailjet_email(message)
    Mailjet::Send.create(
      message,
    )
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
