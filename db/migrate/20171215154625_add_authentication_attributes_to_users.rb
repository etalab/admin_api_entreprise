class AddAuthenticationAttributesToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :password_digest,      :string, null: false, default: ''
    add_column :users, :confirmation_token,   :string
    add_column :users, :confirmed_at,         :datetime
    add_column :users, :confirmation_sent_at, :datetime

    add_index :users, :confirmation_token, unique: true
  end
end
