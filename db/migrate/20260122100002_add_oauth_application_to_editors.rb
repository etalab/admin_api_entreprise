class AddOAuthApplicationToEditors < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :editors, :oauth_application, type: :uuid, index: { algorithm: :concurrently }
  end
end
