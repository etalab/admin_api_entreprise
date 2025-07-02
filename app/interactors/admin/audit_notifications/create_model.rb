class Admin::AuditNotifications::CreateModel < ApplicationInteractor
  def call
    context.audit_notification = AuditNotification.new(audit_notification_create_params)

    return if context.audit_notification.save

    context.fail!
  end

  private

  def audit_notification_create_params
    {

      authorization_request_external_id: context.audit_notification_params[:authorization_request_external_id],
      reason: context.audit_notification_params[:reason],
      approximate_volume: context.audit_notification_params[:approximate_volume],
      request_id_access_logs:,
      contact_emails:
    }
  end

  def request_id_access_logs
    input = context.audit_notification_params[:request_id_access_logs_input] || ''
    input.split(/[\n,]/).map(&:strip).compact_blank.uniq
  end

  def contact_emails
    external_id = context.audit_notification_params[:authorization_request_external_id]
    authorization_request = AuthorizationRequest.find_by(external_id: external_id)

    return [] unless authorization_request

    emails = []
    emails << authorization_request.demandeur&.email
    emails << authorization_request.contact_technique&.email
    emails << authorization_request.contact_metier&.email

    emails.compact.uniq
  end
end
