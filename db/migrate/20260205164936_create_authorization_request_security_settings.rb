class CreateAuthorizationRequestSecuritySettings < ActiveRecord::Migration[7.2]
  def change
    create_table :authorization_request_security_settings, id: :uuid do |t|
      t.references :authorization_request, type: :uuid, null: false, foreign_key: true, index: { unique: true }
      t.integer :rate_limit_per_minute
      t.jsonb :allowed_ips, default: []

      t.timestamps
    end
  end
end
