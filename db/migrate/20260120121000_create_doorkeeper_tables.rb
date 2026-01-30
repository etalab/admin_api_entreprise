class CreateDoorkeeperTables < ActiveRecord::Migration[7.0]
  def change
    create_table :oauth_applications, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :name, null: false
      t.string :uid, null: false
      t.string :secret, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, null: false, default: ''
      t.boolean :confidential, null: false, default: true
      t.timestamps
    end

    add_index :oauth_applications, :uid, unique: true

    create_table :oauth_access_grants, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :resource_owner, null: false, type: :uuid, foreign_key: { to_table: :users }
      t.references :application, null: false, type: :uuid, foreign_key: { to_table: :oauth_applications }
      t.string :token, null: false
      t.integer :expires_in, null: false
      t.text :redirect_uri, null: false
      t.datetime :created_at, null: false
      t.datetime :revoked_at
      t.string :scopes, null: false, default: ''
      t.string :code_challenge
      t.string :code_challenge_method
      t.jsonb :token_ids, null: false, default: []
      t.string :state
    end

    add_index :oauth_access_grants, :token, unique: true

    create_table :oauth_access_tokens, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.references :resource_owner, type: :uuid, foreign_key: { to_table: :users }
      t.references :application, null: false, type: :uuid, foreign_key: { to_table: :oauth_applications }
      t.string :token, null: false
      t.string :refresh_token
      t.integer :expires_in
      t.datetime :revoked_at
      t.datetime :created_at, null: false
      t.string :scopes
      t.string :previous_refresh_token, null: false, default: ''
      t.jsonb :token_ids, null: false, default: []
    end

    add_index :oauth_access_tokens, :token, unique: true
    add_index :oauth_access_tokens, :refresh_token, unique: true
  end
end
