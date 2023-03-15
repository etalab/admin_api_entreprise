class AddScopesToToken < ActiveRecord::Migration[7.0]
  def up
    add_column :tokens, :scopes, :jsonb, default: [], null: false
    add_index  :tokens, :scopes, using: :gin

    Token.includes(:old_scopes).find_each do |token|
      token.update!(scopes: token.old_scopes.pluck(:code))
    end
  end

  def down
    remove_column :tokens, :scopes
  end
end
