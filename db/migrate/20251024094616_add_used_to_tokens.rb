class AddUsedToTokens < ActiveRecord::Migration[8.0]
  def change
    add_column :tokens, :used, :boolean, default: false, null: false
  end
end
