class AddConstraintOnEmails < ActiveRecord::Migration[6.1]
  def up
    add_index :users, :email, unique: true
  end

  def down
    remove_index :users, name: :index_users_on_email
  end
end
