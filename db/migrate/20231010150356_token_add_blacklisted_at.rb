class TokenAddBlacklistedAt < ActiveRecord::Migration[7.1]
  def up
    add_column :tokens, :blacklisted_at, :datetime, default: nil, null: true 
    Token.where(blacklisted: true).update_all(blacklisted_at: Time.zone.now)
  end

  def down
    remove_column :tokens, :blacklisted_at
  end
end
