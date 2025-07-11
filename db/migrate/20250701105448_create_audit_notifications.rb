class CreateAuditNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_notifications, id: :uuid do |t|
      t.string :reason, null: false
      t.string :authorization_request_external_id, null: false
      t.string :request_id_access_logs, array: true, default: [], null: false
      t.string :contact_emails, array: true, default: [], null: false
      t.integer :approximate_volume

      t.timestamps
    end

    add_index :audit_notifications, :authorization_request_external_id
    add_index :audit_notifications, :created_at
  end
end
