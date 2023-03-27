class DropScopes < ActiveRecord::Migration[7.0]
  def change
    drop_table :scopes
  end
end
