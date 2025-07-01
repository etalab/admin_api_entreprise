module AuditMailersCommons
  extend ActiveSupport::Concern

  included { before_action :attach_logos }

  def notify
    @audit_notification = params[:audit_notification]
    @authorization_request = @audit_notification.authorization_request
    @logs = @audit_notification.access_logs.order(timestamp: :desc).limit(10)

    mail(
      to: extract_contact_emails(@authorization_request),
      subject: t('api_entreprise.audit_mailer.notify.subject', id: @authorization_request.external_id)
    )
  end

  private

  def extract_contact_emails(authorization_request)
    %w[
      demandeur
      contact_technique
      contact_metier
    ].map { |role|
      authorization_request.public_send(role)&.email
    }.compact.uniq
  end
end
