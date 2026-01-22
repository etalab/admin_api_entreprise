class AddOAuthApplicationToAuthorizationRequests < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :authorization_requests, :oauth_application, type: :uuid, index: { algorithm: :concurrently }
  end
end
