class Admin::AuditNotifications::SendEmail < ApplicationInteractor
  def call
    mailer.with(
      audit_notification: context.audit_notification
    ).notify.deliver_later
  end

  private

  def mailer
    namespace.constantize::AuditMailer
  end

  def namespace
    "api_#{context.namespace}".camelize
  end
end
