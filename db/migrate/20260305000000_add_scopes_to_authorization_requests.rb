class AddScopesToAuthorizationRequests < ActiveRecord::Migration[8.1]
  def change # rubocop:disable Metrics/MethodLength
    add_column :authorization_requests, :scopes, :jsonb, default: [], null: false

    reversible do |dir|
      dir.up do
        safety_assured do
          execute <<~SQL.squish
            UPDATE authorization_requests
            SET scopes = (
              SELECT tokens.scopes
              FROM tokens
              WHERE tokens.authorization_request_model_id = authorization_requests.id
              ORDER BY tokens.exp DESC
              LIMIT 1
            )
            WHERE EXISTS (
              SELECT 1 FROM tokens WHERE tokens.authorization_request_model_id = authorization_requests.id
            )
          SQL
        end
      end
    end
  end
end
