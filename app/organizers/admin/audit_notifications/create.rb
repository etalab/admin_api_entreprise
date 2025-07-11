class Admin::AuditNotifications::Create < ApplicationOrganizer
  organize Admin::AuditNotifications::CreateModel,
    Admin::AuditNotifications::SendEmail
end
