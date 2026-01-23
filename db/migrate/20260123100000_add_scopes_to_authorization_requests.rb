class AddScopesToAuthorizationRequests < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :authorization_requests, :scopes, :jsonb, default: [], null: false
    add_index :authorization_requests, :scopes, using: :gin, algorithm: :concurrently
  end
end
