class AddPublicIdToAuthorizationRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :authorization_requests, :public_id, :uuid
  end
end
