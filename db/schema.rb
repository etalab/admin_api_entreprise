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

ActiveRecord::Schema[7.1].define(version: 2023_10_10_150356) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "authorization_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "intitule"
    t.string "description"
    t.string "external_id"
    t.string "status"
    t.datetime "last_update", precision: nil
    t.datetime "first_submitted_at", precision: nil
    t.datetime "validated_at", precision: nil
    t.datetime "created_at", precision: nil
    t.string "previous_external_id"
    t.string "siret"
    t.string "api", null: false
    t.string "demarche"
    t.index ["external_id"], name: "index_authorization_requests_on_external_id", unique: true, where: "(external_id IS NOT NULL)"
  end

  create_table "magic_links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "access_token", null: false
    t.datetime "expires_at", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "token_id"
    t.index ["access_token"], name: "index_magic_links_on_access_token", unique: true
    t.index ["token_id"], name: "index_magic_links_on_token_id"
  end

  create_table "tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.datetime "blacklisted_at"
    t.index ["access_request_survey_sent"], name: "index_tokens_on_access_request_survey_sent"
    t.index ["archived"], name: "index_tokens_on_archived"
    t.index ["blacklisted"], name: "index_tokens_on_blacklisted"
    t.index ["created_at"], name: "index_tokens_on_created_at"
    t.index ["exp"], name: "index_tokens_on_exp"
    t.index ["iat"], name: "index_tokens_on_iat"
    t.index ["scopes"], name: "index_tokens_on_scopes", using: :gin
  end

  create_table "user_authorization_request_roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "authorization_request_id", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "authorization_request_id", "role"], name: "index_authorization_id_user_id_role", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "oauth_api_gouv_id"
    t.boolean "tokens_newly_transfered", default: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "magic_links", "tokens"
  add_foreign_key "user_authorization_request_roles", "authorization_requests"
  add_foreign_key "user_authorization_request_roles", "users"
end
