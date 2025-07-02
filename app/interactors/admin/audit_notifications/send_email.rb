class Admin::AuditNotifications::SendEmail < ApplicationInteractor
  def call
    APIEntreprise::AuditMailer.with(
      audit_notification: context.audit_notification
    ).notify.deliver_later
  end
end
