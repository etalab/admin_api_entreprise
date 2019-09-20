class DropUsersTokenCreation < ActiveRecord::Migration[6.0]
  # Drop everything in the database shema related to user token creation
  def change
    drop_table :roles_users
    remove_column :jwt_api_entreprises, :contact_id
    remove_column :users, :allow_token_creation
  end
end
