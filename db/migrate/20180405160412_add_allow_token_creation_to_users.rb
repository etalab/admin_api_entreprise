class AddAllowTokenCreationToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :allow_token_creation, :boolean, default: false
  end
end
