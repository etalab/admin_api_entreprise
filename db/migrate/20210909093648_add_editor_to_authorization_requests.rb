class AddEditorToAuthorizationRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :authorization_requests, :editor, :string
  end
end
