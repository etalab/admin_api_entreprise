class ScheduleAuthorizationRequestEmailJob < ApplicationJob
  include MailjetHelpers

  queue_as :default

  attr_reader :authorization_request

  def perform(authorization_request_id, authorization_request_status, mail_attributes)
    @authorization_request = AuthorizationRequest.find_by(id: authorization_request_id)

    return if authorization_request.blank?
    return if authorization_request_status_changed?(authorization_request_status)

    deliver_email(mail_attributes)
  end

  private

  def deliver_email(mail_attributes)
    interesting_mail_attributes = {
      to: mail_attributes[:to],
      cc: mail_attributes[:cc]
    }.compact

    api_klass = "#{API}#{@authorization_request.api.capitalize}".constantize

    mail_klass = "#{api_klass}::AuthorizationRequestMailer".constantize

    mail_klass.public_send(mail_attributes[:template_name].to_sym, interesting_mail_attributes)
  end

  def build_message(mail_attributes)
    {
      from_name: from_name(@authorization_request.api),
      from_email: from_email(@authorization_request.api),
      to: build_recipient_attributes(mail_attributes['to']),
      cc: build_recipient_attributes(mail_attributes['cc']),
      vars: mail_attributes['vars'],
      'Mj-TemplateLanguage' => true,
      'Mj-TemplateID' => mail_attributes['template_id']
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
