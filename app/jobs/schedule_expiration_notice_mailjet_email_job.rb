class ScheduleExpirationNoticeMailjetEmailJob < ApplicationJob
  include MailjetHelpers
  include FriendlyDateHelper

  queue_as :default

  def perform(jwt_id, expires_in)
    return if expiration_in_to_mailjet_template_id(expires_in).nil?

    token = JwtAPIEntreprise.find_by(id: jwt_id)
    return if token.nil?

    deliver_mailjet_email(
      build_message(token, expires_in).stringify_keys
    )
  rescue Mailjet::ApiError => e
    set_mailjet_context_for_sentry(e)
    raise
  end

  private

  def build_message(token, expires_in)
    {
      from_name: 'API Entreprise',
      from_email: Rails.configuration.emails_sender_address,
      to: build_recipient(token),
      vars: build_vars(token),
      'Mj-TemplateLanguage' => true,
      'Mj-TemplateID' => expiration_in_to_mailjet_template_id(expires_in)
    }
  end

  def build_recipient(token)
    user = token.user

    "#{user.full_name} <#{user.email}>"
  end

  def build_vars(token)
    {
      cadre_utilisation_token: token.subject,
      authorization_request_id: token.authorization_request.external_id,
      expiration_date: friendly_format_from_timestamp(token.exp)
    }
  end

  def expiration_in_to_mailjet_template_id(expires_in)
    {
      90 => 3139223,
      60 => 3139257,
      30 => 3139276,
      15 => 3139289,
      7 => 3139312,
      0 => 3139339
    }[expires_in]
  end
end
