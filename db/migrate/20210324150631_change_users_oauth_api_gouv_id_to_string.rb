class ChangeUsersOAuthAPIGouvIdToString < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :oauth_api_gouv_id, :string
  end
end
