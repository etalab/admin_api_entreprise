class APIParticulier::AuditMailerPreview < ActionMailer::Preview
  def notify
    APIParticulier::AuditMailer.with(
      audit_notification:
    ).notify
  end

  private

  def audit_notification
    AuditNotification.first
  end
end
