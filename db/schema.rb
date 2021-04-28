# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_28_134253) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "phone_number"
    t.string "contact_type"
    t.uuid "jwt_api_entreprise_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["jwt_api_entreprise_id"], name: "index_contacts_on_jwt_api_entreprise_id"
  end

  create_table "incidents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.string "subtitle"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jwt_api_entreprises", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "subject"
    t.integer "iat"
    t.uuid "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "exp"
    t.string "version"
    t.boolean "blacklisted", default: false
    t.json "days_left_notification_sent", default: [], null: false
    t.boolean "archived", default: false
    t.string "temp_use_case"
    t.string "authorization_request_id"
    t.boolean "access_request_survey_sent", default: false, null: false
    t.string "magic_link_token"
    t.datetime "magic_link_issuance_date"
    t.index ["access_request_survey_sent"], name: "index_jwt_api_entreprises_on_access_request_survey_sent"
    t.index ["created_at"], name: "index_jwt_api_entreprises_on_created_at"
    t.index ["iat"], name: "index_jwt_api_entreprises_on_iat"
    t.index ["magic_link_token"], name: "index_jwt_api_entreprises_on_magic_link_token", unique: true
    t.index ["user_id"], name: "index_jwt_api_entreprises_on_user_id"
  end

  create_table "jwt_api_entreprises_roles", id: false, force: :cascade do |t|
    t.uuid "jwt_api_entreprise_id", null: false
    t.uuid "role_id", null: false
  end

  create_table "oauth_access_grants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_owner_id", null: false
    t.uuid "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "resource_owner_id"
    t.uuid "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "confidential", default: true, null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.string "context"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest", default: "", null: false
    t.datetime "cgu_agreement_date"
    t.text "note", default: ""
    t.string "pwd_renewal_token"
    t.datetime "pwd_renewal_token_sent_at"
    t.string "oauth_api_gouv_id"
    t.boolean "admin", default: false
    t.boolean "tokens_newly_transfered", default: false
    t.index ["pwd_renewal_token"], name: "index_users_on_pwd_renewal_token"
  end

  add_foreign_key "contacts", "jwt_api_entreprises"
  add_foreign_key "jwt_api_entreprises", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
end
