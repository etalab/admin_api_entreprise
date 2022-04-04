class AddSiretToAuthorizationRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :authorization_requests, :siret, :string
  end
end
