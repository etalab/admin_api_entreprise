class AddConstraintOnAPIFieldOnAuthorizationRequests < ActiveRecord::Migration[7.0]
  def change
    change_column_null :authorization_requests, :api, false
  end
end
