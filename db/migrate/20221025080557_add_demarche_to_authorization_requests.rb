class AddDemarcheToAuthorizationRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :authorization_requests, :demarche, :string
  end
end
