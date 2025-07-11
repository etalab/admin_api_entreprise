class APIEntreprise::AuditMailerPreview < ActionMailer::Preview
  def notify
    APIEntreprise::AuditMailer.with(
      audit_notification:
    ).notify
  end

  private

  def audit_notification
    AuditNotification.first
  end
end
