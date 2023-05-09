class ScheduleExpirationNoticeMailjetEmailJob < ApplicationJob
  include MailjetHelpers
  include FriendlyDateHelper

  queue_as :default

  def perform(token_id, expires_in)
    return if expiration_in_to_mailjet_template_id(expires_in).nil?

    token = Token.find_by(id: token_id)
    return if token.nil? || token.authorization_request.nil?

    deliver_mailjet_email(
      build_message(token, expires_in).stringify_keys
    )
  rescue Mailjet::ApiError => e
    affect_mailjet_context_for_sentry(e)
    raise
  end

  private

  def build_message(token, expires_in)
    {
      from_name: 'API Entreprise',
      from_email: Rails.configuration.emails_sender_address,
      to: build_recipients(token),
      vars: build_vars(token),
      'Mj-TemplateLanguage' => true,
      'Mj-TemplateID' => expiration_in_to_mailjet_template_id(expires_in)
    }
  end

  def build_recipients(token)
    token.users.map { |recipient|
      "#{recipient.full_name} <#{recipient.email}>"
    }.uniq.join(', ')
  end

  def build_vars(token)
    {
      cadre_utilisation_token: token.intitule,
      authorization_request_id: token.authorization_request.external_id,
      expiration_date: friendly_format_from_timestamp(token.exp)
    }
  end

  def expiration_in_to_mailjet_template_id(expires_in)
    {
      90 => 3_139_223,
      60 => 3_139_257,
      30 => 3_139_276,
      15 => 3_139_289,
      7 => 3_139_312,
      0 => 3_139_339
    }[expires_in]
  end
end
