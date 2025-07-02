class Admin::AuditNotificationsController < AdminController
  def index
    @audit_notifications = AuditNotification.order(created_at: :desc).page(params[:page])
  end

  def new
    @audit_notification = AuditNotification.new
  end

  def create
    result = Admin::AuditNotifications::Create.call(audit_notification_params: audit_notification_params)

    if result.success?
      success_message(title: "La notification d'audit a été envoyé avec succès")
      redirect_to admin_audit_notifications_path
    else
      @audit_notification = result.audit_notification || AuditNotification.new(audit_notification_params)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def audit_notification_params
    params.expect(audit_notification: %i[authorization_request_external_id request_id_access_logs_input reason approximate_volume])
  end
end
