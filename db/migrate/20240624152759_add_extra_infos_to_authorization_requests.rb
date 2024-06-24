class AddExtraInfosToAuthorizationRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :authorization_requests, :extra_infos, :jsonb, default: {}
  end
end
