class TokenRemoveBlacklistedArchived < ActiveRecord::Migration[7.1]
  def up
    safety_assured { remove_column :tokens, :blacklisted }
    safety_assured { remove_column :tokens, :archived }
  end

  def down
    add_column :tokens, :blacklisted, :boolean, default: false
    add_column :tokens, :archived, :boolean, default: false

    Token.where.not(blacklisted_at: nil).update_all(blacklisted: true)
  end
end
