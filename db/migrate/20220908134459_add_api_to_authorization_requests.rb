class AddAPIToAuthorizationRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :authorization_requests, :api, :string
  end
end
