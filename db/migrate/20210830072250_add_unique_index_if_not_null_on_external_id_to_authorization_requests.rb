class AddUniqueIndexIfNotNullOnExternalIdToAuthorizationRequests < ActiveRecord::Migration[6.1]
  def change
    add_index :authorization_requests, :external_id, unique: true, where: 'external_id IS NOT NULL'
  end
end
