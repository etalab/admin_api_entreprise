class InitialSchema < ActiveRecord::Migration[7.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "btree_gin"
    enable_extension "pgcrypto"
    enable_extension "plpgsql"

    create_table "authorization_requests", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string "intitule"
      t.string "description"
      t.string "external_id"
      t.string "status"
      t.datetime "last_update", precision: nil
      t.datetime "first_submitted_at", precision: nil
      t.datetime "validated_at", precision: nil
      t.datetime "created_at", precision: nil
      t.uuid "user_id", null: false
      t.string "previous_external_id"
      t.string "siret"
      t.string "api", null: false
      t.string "demarche"
      t.index ["external_id"], name: "index_authorization_requests_on_external_id", unique: true, where: "(external_id IS NOT NULL)"
    end

    if Rails.env.local?
      create_table "access_logs", id: false, force: :cascade do |t|
        t.timestamptz "timestamp"
        t.uuid "token_id"
      end
    end

    create_table "contacts", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string "email", null: false
      t.string "phone_number"
      t.string "contact_type", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.uuid "authorization_request_id"
      t.string "first_name"
      t.string "last_name"
      t.index ["created_at"], name: "index_contacts_on_created_at"
    end

    create_table "magic_links", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string "email", null: false
      t.string "access_token", null: false
      t.datetime "expires_at", precision: nil, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.uuid "token_id"
      t.index ["access_token"], name: "index_magic_links_on_access_token", unique: true
      t.index ["token_id"], name: "index_magic_links_on_token_id"
    end

    create_table "scopes_tokens", id: false do |t|
      t.uuid "token_id", null: false
      t.uuid "scope_id", null: false
    end

    create_table "tokens", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.integer "iat"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "exp", null: false
      t.string "version"
      t.boolean "blacklisted", default: false
      t.json "days_left_notification_sent", default: [], null: false
      t.boolean "archived", default: false
      t.string "temp_use_case"
      t.string "authorization_request_id"
      t.boolean "access_request_survey_sent", default: false, null: false
      t.uuid "authorization_request_model_id", null: false
      t.json "extra_info"
      t.jsonb "scopes", default: [], null: false
      t.index ["access_request_survey_sent"], name: "index_tokens_on_access_request_survey_sent"
      t.index ["archived"], name: "index_tokens_on_archived"
      t.index ["blacklisted"], name: "index_tokens_on_blacklisted"
      t.index ["created_at"], name: "index_tokens_on_created_at"
      t.index ["exp"], name: "index_tokens_on_exp"
      t.index ["iat"], name: "index_tokens_on_iat"
      t.index ["scopes"], name: "index_tokens_on_scopes", using: :gin
    end

    create_table "users", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string "email"
      t.string "context"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.datetime "cgu_agreement_date", precision: nil
      t.text "note", default: ""
      t.string "pwd_renewal_token"
      t.datetime "pwd_renewal_token_sent_at", precision: nil
      t.string "oauth_api_gouv_id"
      t.boolean "admin", default: false
      t.boolean "tokens_newly_transfered", default: false
      t.string "first_name"
      t.string "last_name"
      t.string "phone_number"
      t.index ["created_at"], name: "index_users_on_created_at"
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["pwd_renewal_token"], name: "index_users_on_pwd_renewal_token"
    end

    add_foreign_key "magic_links", "tokens"
  end
end
