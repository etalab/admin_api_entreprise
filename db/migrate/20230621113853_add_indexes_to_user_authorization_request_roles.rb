class AddIndexesToUserAuthorizationRequestRoles < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :user_authorization_request_roles, %i[user_id authorization_request_id role], unique: true, algorithm: :concurrently, name: 'index_authorization_id_user_id_role'
  end
end
