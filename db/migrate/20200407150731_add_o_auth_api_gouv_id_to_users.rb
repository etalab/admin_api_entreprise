class AddOAuthApiGouvIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :oauth_api_gouv_id, :integer, default: nil
  end
end
