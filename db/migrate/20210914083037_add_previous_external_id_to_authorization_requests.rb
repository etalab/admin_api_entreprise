class AddPreviousExternalIdToAuthorizationRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :authorization_requests, :previous_external_id, :string
  end
end
