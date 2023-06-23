class RemoveScopesTables < ActiveRecord::Migration[7.0]
  def up
    drop_table :scopes, if_exists: true
    drop_table :scopes_tokens, if_exists: true
  end

  def down; end
end
