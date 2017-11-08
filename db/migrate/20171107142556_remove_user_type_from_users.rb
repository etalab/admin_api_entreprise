class RemoveUserTypeFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :user_type, :string
  end
end
