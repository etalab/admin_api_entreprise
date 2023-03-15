class AddScopesAsJsonbToToken < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :scopes_as_jsonb, :jsonb, null: false, default: []
    add_index  :tokens, :scopes_as_jsonb, using: :gin
    Token.all.each do |token|
      scopes_as_jsonb = []
      token.scopes.each do |scope|
        scopes_as_jsonb << { name: scope.name, code: scope.code, api: scope.api}
      end
      token.update!(scopes_as_jsonb: scopes_as_jsonb)
    end
  end
end
