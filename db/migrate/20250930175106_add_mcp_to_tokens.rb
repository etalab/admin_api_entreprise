class AddMcpToTokens < ActiveRecord::Migration[8.0]
  def change
    add_column :tokens, :mcp, :boolean, default: false, null: false
  end
end
