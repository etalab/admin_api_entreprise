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

ActiveRecord::Schema[8.1].define(version: 2026_01_14_112301) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "access_logs", id: false, force: :cascade do |t|
    t.string "path", null: false
    t.uuid "request_id", null: false
    t.timestamptz "timestamp", null: false
    t.uuid "token_id"
  end

  create_table "audit_notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "approximate_volume"
    t.string "authorization_request_external_id", null: false
    t.string "contact_emails", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.string "reason", null: false
    t.string "request_id_access_logs", default: [], null: false, array: true
    t.datetime "updated_at", null: false
    t.index ["authorization_request_external_id"], name: "index_audit_notifications_on_authorization_request_external_id"
    t.index ["created_at"], name: "index_audit_notifications_on_created_at"
  end

  create_table "authorization_requests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "api", null: false
    t.datetime "created_at", precision: nil
    t.string "demarche"
    t.string "description"
    t.string "external_id"
    t.jsonb "extra_infos", default: {}
    t.datetime "first_submitted_at", precision: nil
    t.string "intitule"
    t.datetime "last_update", precision: nil
    t.string "previous_external_id"
    t.uuid "public_id"
    t.string "siret"
    t.string "status"
    t.datetime "validated_at", precision: nil
    t.index ["external_id"], name: "index_authorization_requests_on_external_id", unique: true, where: "(external_id IS NOT NULL)"
  end

  create_table "editors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "copy_token", default: false, null: false
    t.datetime "created_at", null: false
    t.string "form_uids", default: [], array: true
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "callback_priority"
    t.text "callback_queue_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
    t.jsonb "serialized_properties"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id", null: false
    t.datetime "created_at", null: false
    t.interval "duration"
    t.text "error"
    t.text "error_backtrace", array: true
    t.integer "error_event", limit: 2
    t.datetime "finished_at"
    t.text "job_class"
    t.uuid "process_id"
    t.text "queue_name"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_type", limit: 2
    t.jsonb "state"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.text "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "cron_at"
    t.text "cron_key"
    t.text "error"
    t.integer "error_event", limit: 2
    t.integer "executions_count"
    t.datetime "finished_at"
    t.boolean "is_discrete"
    t.text "job_class"
    t.text "labels", array: true
    t.datetime "locked_at"
    t.uuid "locked_by_id"
    t.datetime "performed_at"
    t.integer "priority"
    t.text "queue_name"
    t.uuid "retried_good_job_id"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "magic_links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "access_token", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "expires_at", precision: nil, null: false
    t.uuid "token_id"
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_magic_links_on_access_token", unique: true
    t.index ["token_id"], name: "index_magic_links_on_token_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "insee_payload", default: {}
    t.datetime "last_insee_payload_updated_at"
    t.string "siret", null: false
    t.datetime "updated_at", null: false
    t.index ["siret"], name: "index_organizations_on_siret", unique: true
    t.check_constraint "length(siret::text) = 14", name: "siret_length_check"
  end

  create_table "prolong_token_wizards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "contact_metier"
    t.boolean "contact_technique"
    t.datetime "created_at", null: false
    t.string "owner"
    t.boolean "project_purpose"
    t.integer "status"
    t.uuid "token_id", null: false
    t.datetime "updated_at", null: false
    t.index ["token_id"], name: "index_prolong_token_wizards_on_token_id"
  end

  create_table "tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "authorization_request_id"
    t.uuid "authorization_request_model_id", null: false
    t.datetime "blacklisted_at"
    t.datetime "created_at", precision: nil, null: false
    t.jsonb "days_left_notification_sent", default: [], null: false
    t.integer "exp", null: false
    t.jsonb "extra_info", default: {}
    t.integer "iat"
    t.boolean "mcp", default: false, null: false
    t.jsonb "scopes", default: [], null: false
    t.string "temp_use_case"
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "used", default: false, null: false
    t.string "version"
    t.index ["created_at"], name: "index_tokens_on_created_at"
    t.index ["exp"], name: "index_tokens_on_exp"
    t.index ["iat"], name: "index_tokens_on_iat"
    t.index ["scopes"], name: "index_tokens_on_scopes", using: :gin
  end

  create_table "user_authorization_request_roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "authorization_request_id", null: false
    t.datetime "created_at", null: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "authorization_request_id", "role"], name: "index_authorization_id_user_id_role", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "editor_id"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "oauth_api_gouv_id"
    t.string "phone_number"
    t.string "provider_uids", default: [], null: false, array: true
    t.boolean "tokens_newly_transfered", default: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["editor_id"], name: "index_users_on_editor_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "magic_links", "tokens"
  add_foreign_key "prolong_token_wizards", "tokens"
  add_foreign_key "user_authorization_request_roles", "authorization_requests"
  add_foreign_key "user_authorization_request_roles", "users"
end
