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

ActiveRecord::Schema[7.0].define(version: 2022_04_25_161454) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "access_logs", id: false, force: :cascade do |t|
    t.datetime "timestamp", precision: nil
    t.string "action"
    t.string "api_version"
    t.string "host"
    t.string "method"
    t.string "path"
    t.string "route"
    t.string "controller"
    t.string "duration"
    t.string "status"
    t.string "ip"
    t.string "source"
    t.jsonb "params", default: "{}"
    t.uuid "jwt_api_entreprise_id"
    t.boolean "cached", default: false
    t.index "((params ->> 'recipient'::text))", name: "index_access_logs_on_params_recipient", using: :gin
    t.index "((params ->> 'siren'::text))", name: "index_access_logs_on_params_siren", using: :gin
    t.index "((params ->> 'siret'::text))", name: "index_access_logs_on_params_siret", using: :gin
    t.index "((params ->> 'siret_or_eori'::text))", name: "index_access_logs_on_params_siret_or_eori", using: :gin
    t.index ["jwt_api_entreprise_id"], name: "index_access_logs_on_jwt_api_entreprise_id", where: "(jwt_api_entreprise_id IS NOT NULL)"
  end

  create_table "authorization_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.index ["external_id"], name: "index_authorization_requests_on_external_id", unique: true, where: "(external_id IS NOT NULL)"
  end

  create_table "contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

  create_table "jwt_api_entreprises", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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
    t.string "magic_link_token"
    t.datetime "magic_link_issuance_date", precision: nil
    t.uuid "authorization_request_model_id", null: false
    t.index ["access_request_survey_sent"], name: "index_jwt_api_entreprises_on_access_request_survey_sent"
    t.index ["archived"], name: "index_jwt_api_entreprises_on_archived"
    t.index ["blacklisted"], name: "index_jwt_api_entreprises_on_blacklisted"
    t.index ["created_at"], name: "index_jwt_api_entreprises_on_created_at"
    t.index ["exp"], name: "index_jwt_api_entreprises_on_exp"
    t.index ["iat"], name: "index_jwt_api_entreprises_on_iat"
    t.index ["magic_link_token"], name: "index_jwt_api_entreprises_on_magic_link_token", unique: true
  end

  create_table "jwt_api_entreprises_roles", id: false, force: :cascade do |t|
    t.uuid "jwt_api_entreprise_id", null: false
    t.uuid "role_id", null: false
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "code"
    t.index ["created_at"], name: "index_roles_on_created_at"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
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

end
