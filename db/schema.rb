# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170419144544) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounting_accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string   "name", null: false
    t.string   "qb_account_classification"
    t.string   "qb_id", null: false
    t.json     "quickbooks_data"
    t.datetime "updated_at", null: false
  end

  add_index "accounting_accounts", ["qb_id"], name: "index_accounting_accounts_on_qb_id", using: :btree

  create_table "accounting_transactions", force: :cascade do |t|
    t.integer  "accounting_account_id"
    t.datetime "created_at", null: false
    t.integer  "project_id"
    t.string   "qb_id", null: false
    t.string   "qb_transaction_type", null: false
    t.json     "quickbooks_data"
    t.datetime "updated_at", null: false
  end

  add_index "accounting_transactions", ["accounting_account_id"], name: "index_accounting_transactions_on_accounting_account_id", using: :btree
  add_index "accounting_transactions", ["project_id"], name: "index_accounting_transactions_on_project_id", using: :btree
  add_index "accounting_transactions", ["qb_id", "qb_transaction_type"], name: "acc_trans_qbid_qbtype__unq_idx", unique: true, using: :btree
  add_index "accounting_transactions", ["qb_id"], name: "index_accounting_transactions_on_qb_id", using: :btree
  add_index "accounting_transactions", ["qb_transaction_type"], name: "index_accounting_transactions_on_qb_transaction_type", using: :btree

  create_table "countries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer  "default_currency_id"
    t.string   "iso_code", limit: 2
    t.string   "name"
    t.datetime "updated_at", null: false
  end

  create_table "currencies", force: :cascade do |t|
    t.string   "code"
    t.datetime "created_at", null: false
    t.string   "name"
    t.string   "short_symbol"
    t.string   "symbol"
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "attempts", default: 0, null: false
    t.datetime "created_at"
    t.datetime "failed_at"
    t.text     "handler", null: false
    t.text     "last_error"
    t.datetime "locked_at"
    t.string   "locked_by"
    t.integer  "priority", default: 0, null: false
    t.string   "queue"
    t.datetime "run_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "division_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
  end

  add_index "division_hierarchies", %w(ancestor_id descendant_id generations), name: "division_anc_desc_idx", unique: true, using: :btree
  add_index "division_hierarchies", ["descendant_id"], name: "division_desc_idx", using: :btree

  create_table "divisions", force: :cascade do |t|
    t.string   "accent_fg_color"
    t.string   "accent_main_color"
    t.string   "banner_bg_color"
    t.string   "banner_fg_color"
    t.datetime "created_at", null: false
    t.integer  "currency_id"
    t.json     "custom_data"
    t.text     "description"
    t.integer  "interest_income_account_id"
    t.integer  "interest_receivable_account_id"
    t.string   "internal_name"
    t.json     "locales"
    t.string   "logo_content_type"
    t.string   "logo_file_name"
    t.integer  "logo_file_size"
    t.string   "logo_text"
    t.datetime "logo_updated_at"
    t.string   "name"
    t.boolean  "notify_on_new_logs", default: false
    t.integer  "organization_id"
    t.integer  "parent_id"
    t.integer  "principal_account_id"
    t.json     "quickbooks_data"
    t.datetime "updated_at", null: false
  end

  add_index "divisions", ["currency_id"], name: "index_divisions_on_currency_id", using: :btree
  add_index "divisions", ["interest_income_account_id"], name: "index_divisions_on_interest_income_account_id", using: :btree
  add_index "divisions", ["interest_receivable_account_id"], name: "index_divisions_on_interest_receivable_account_id", using: :btree
  add_index "divisions", ["organization_id"], name: "index_divisions_on_organization_id", using: :btree
  add_index "divisions", ["principal_account_id"], name: "index_divisions_on_principal_account_id", using: :btree

  create_table "loan_health_checks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean  "has_late_steps"
    t.boolean  "has_sporadic_updates"
    t.date     "last_log_date"
    t.integer  "loan_id"
    t.boolean  "missing_contract"
    t.decimal  "progress_pct"
    t.datetime "updated_at", null: false
  end

  add_index "loan_health_checks", ["loan_id"], name: "index_loan_health_checks_on_loan_id", using: :btree

  create_table "loan_question_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
  end

  add_index "loan_question_hierarchies", %w(ancestor_id descendant_id generations), name: "custom_field_anc_desc_idx", unique: true, using: :btree
  add_index "loan_question_hierarchies", ["descendant_id"], name: "custom_field_desc_idx", using: :btree

  create_table "loan_question_requirements", force: :cascade do |t|
    t.decimal "amount"
    t.integer "loan_question_id"
    t.integer "option_id"
  end

  create_table "loan_question_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer  "division_id"
    t.string   "internal_name"
    t.datetime "updated_at", null: false
  end

  add_index "loan_question_sets", ["division_id"], name: "index_loan_question_sets_on_division_id", using: :btree

  create_table "loan_questions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string   "data_type"
    t.boolean  "has_embeddable_media", default: false, null: false
    t.string   "internal_name"
    t.integer  "loan_question_set_id"
    t.integer  "migration_position"
    t.boolean  "override_associations", default: false, null: false
    t.integer  "parent_id"
    t.integer  "position"
    t.boolean  "required", default: false, null: false
    t.string   "status", default: "active", null: false
    t.datetime "updated_at", null: false
  end

  add_index "loan_questions", ["loan_question_set_id"], name: "index_loan_questions_on_loan_question_set_id", using: :btree

  create_table "loan_response_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json     "custom_data"
    t.string   "kind"
    t.integer  "loan_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "media", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string   "item"
    t.string   "item_content_type"
    t.integer  "item_file_size"
    t.integer  "item_height"
    t.integer  "item_width"
    t.string   "kind_value"
    t.integer  "media_attachable_id"
    t.string   "media_attachable_type"
    t.integer  "sort_order"
    t.datetime "updated_at", null: false
    t.integer  "uploader_id"
  end

  add_index "media", ["media_attachable_type", "media_attachable_id"], name: "index_media_on_media_attachable_type_and_media_attachable_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "author_id"
    t.datetime "created_at", null: false
    t.integer  "notable_id"
    t.string   "notable_type"
    t.datetime "updated_at", null: false
  end

  add_index "notes", ["author_id"], name: "index_notes_on_author_id", using: :btree
  add_index "notes", ["notable_type", "notable_id"], name: "index_notes_on_notable_type_and_notable_id", using: :btree

  create_table "option_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer  "division_id", null: false
    t.string   "model_attribute"
    t.string   "model_type"
    t.datetime "updated_at", null: false
  end

  add_index "option_sets", ["division_id"], name: "index_option_sets_on_division_id", using: :btree

  create_table "options", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer  "migration_id"
    t.integer  "option_set_id"
    t.integer  "position"
    t.datetime "updated_at", null: false
    t.string   "value"
  end

  add_index "options", ["option_set_id"], name: "index_options_on_option_set_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "alias"
    t.string   "city"
    t.text     "contact_notes"
    t.integer  "country_id"
    t.datetime "created_at", null: false
    t.json     "custom_data"
    t.integer  "division_id"
    t.string   "email"
    t.string   "fax"
    t.string   "industry"
    t.boolean  "is_recovered"
    t.string   "last_name"
    t.string   "legal_name"
    t.string   "name"
    t.string   "neighborhood"
    t.string   "postal_code"
    t.integer  "primary_contact_id"
    t.string   "primary_phone"
    t.string   "referral_source"
    t.string   "secondary_phone"
    t.string   "sector"
    t.string   "state"
    t.text     "street_address"
    t.string   "tax_no"
    t.datetime "updated_at", null: false
    t.string   "website"
  end

  add_index "organizations", ["division_id"], name: "index_organizations_on_division_id", using: :btree

  create_table "people", force: :cascade do |t|
    t.date     "birth_date"
    t.string   "city"
    t.text     "contact_notes"
    t.integer  "country_id"
    t.datetime "created_at", null: false
    t.integer  "division_id"
    t.string   "email"
    t.string   "fax"
    t.string   "first_name"
    t.boolean  "has_system_access", default: false, null: false
    t.string   "last_name"
    t.string   "legal_name"
    t.string   "name"
    t.string   "neighborhood"
    t.string   "postal_code"
    t.integer  "primary_organization_id"
    t.string   "primary_phone"
    t.string   "secondary_phone"
    t.string   "state"
    t.text     "street_address"
    t.string   "tax_no"
    t.datetime "updated_at", null: false
    t.string   "website"
  end

  add_index "people", ["division_id"], name: "index_people_on_division_id", using: :btree

  create_table "project_logs", force: :cascade do |t|
    t.integer  "agent_id"
    t.datetime "created_at", null: false
    t.date     "date"
    t.date     "date_changed_to"
    t.string   "progress_metric_value"
    t.integer  "project_step_id"
    t.datetime "updated_at", null: false
  end

  add_index "project_logs", ["agent_id"], name: "index_project_logs_on_agent_id", using: :btree
  add_index "project_logs", ["project_step_id"], name: "index_project_logs_on_project_step_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.decimal  "amount"
    t.datetime "created_at", null: false
    t.integer  "currency_id"
    t.json     "custom_data"
    t.integer  "division_id"
    t.date     "end_date"
    t.date     "first_interest_payment_date"
    t.date     "first_payment_date"
    t.integer  "length_months"
    t.string   "loan_type_value"
    t.string   "name"
    t.integer  "organization_id"
    t.integer  "primary_agent_id"
    t.decimal  "projected_return"
    t.string   "public_level_value"
    t.decimal  "rate"
    t.integer  "representative_id"
    t.integer  "secondary_agent_id"
    t.date     "signing_date"
    t.string   "status_value"
    t.string   "type", null: false
    t.datetime "updated_at", null: false
  end

  add_index "projects", ["currency_id"], name: "index_projects_on_currency_id", using: :btree
  add_index "projects", ["division_id"], name: "index_projects_on_division_id", using: :btree
  add_index "projects", ["organization_id"], name: "index_projects_on_organization_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at"
    t.string   "name", null: false
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "updated_at"
  end

  add_index "roles", %w(name resource_type resource_id), name: "index_roles_on_name_and_resource_type_and_resource_id", unique: true, using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "timeline_entries", force: :cascade do |t|
    t.date     "actual_end_date"
    t.integer  "agent_id"
    t.datetime "created_at", null: false
    t.integer  "date_change_count", default: 0, null: false
    t.datetime "finalized_at"
    t.boolean  "is_finalized"
    t.integer  "old_duration_days", default: 0
    t.date     "old_start_date"
    t.integer  "parent_id"
    t.integer  "project_id"
    t.integer  "schedule_parent_id"
    t.integer  "scheduled_duration_days", default: 0
    t.date     "scheduled_start_date"
    t.string   "step_type_value", null: false
    t.string   "type", null: false
    t.datetime "updated_at", null: false
  end

  add_index "timeline_entries", ["agent_id"], name: "index_timeline_entries_on_agent_id", using: :btree
  add_index "timeline_entries", ["project_id"], name: "index_timeline_entries_on_project_id", using: :btree

  create_table "timeline_entry_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
  end

  add_index "timeline_entry_hierarchies", %w(ancestor_id descendant_id generations), name: "timeline_entry_anc_desc_idx", unique: true, using: :btree
  add_index "timeline_entry_hierarchies", ["descendant_id"], name: "timeline_entry_desc_idx", using: :btree

  create_table "translations", force: :cascade do |t|
    t.datetime "created_at"
    t.string   "locale"
    t.text     "text"
    t.string   "translatable_attribute"
    t.integer  "translatable_id"
    t.string   "translatable_type"
    t.datetime "updated_at"
  end

  add_index "translations", ["translatable_type", "translatable_id"], name: "index_translations_on_translatable_type_and_translatable_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.string   "email", default: "", null: false
    t.string   "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.inet     "last_sign_in_ip"
    t.boolean  "notify_on_new_logs", default: true
    t.integer  "profile_id"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string   "reset_password_token"
    t.integer  "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["profile_id"], name: "index_users_on_profile_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", unique: true, using: :btree

  add_foreign_key "accounting_transactions", "accounting_accounts"
  add_foreign_key "accounting_transactions", "projects"
  add_foreign_key "countries", "currencies", column: "default_currency_id"
  add_foreign_key "divisions", "accounting_accounts", column: "interest_income_account_id"
  add_foreign_key "divisions", "accounting_accounts", column: "interest_receivable_account_id"
  add_foreign_key "divisions", "accounting_accounts", column: "principal_account_id"
  add_foreign_key "divisions", "currencies"
  add_foreign_key "divisions", "organizations"
  add_foreign_key "loan_health_checks", "projects", column: "loan_id"
  add_foreign_key "loan_question_sets", "divisions"
  add_foreign_key "loan_questions", "loan_question_sets"
  add_foreign_key "media", "people", column: "uploader_id"
  add_foreign_key "option_sets", "divisions"
  add_foreign_key "options", "option_sets"
  add_foreign_key "organizations", "countries"
  add_foreign_key "organizations", "divisions"
  add_foreign_key "organizations", "people", column: "primary_contact_id"
  add_foreign_key "people", "countries"
  add_foreign_key "people", "divisions"
  add_foreign_key "people", "organizations", column: "primary_organization_id"
  add_foreign_key "project_logs", "people", column: "agent_id"
  add_foreign_key "project_logs", "timeline_entries", column: "project_step_id"
  add_foreign_key "projects", "currencies"
  add_foreign_key "projects", "divisions"
  add_foreign_key "projects", "organizations"
  add_foreign_key "projects", "people", column: "primary_agent_id"
  add_foreign_key "projects", "people", column: "representative_id"
  add_foreign_key "projects", "people", column: "secondary_agent_id"
  add_foreign_key "timeline_entries", "people", column: "agent_id"
  add_foreign_key "timeline_entries", "projects"
  add_foreign_key "timeline_entries", "timeline_entries", column: "parent_id"
  add_foreign_key "timeline_entries", "timeline_entries", column: "schedule_parent_id"
  add_foreign_key "users", "people", column: "profile_id"
  add_foreign_key "users_roles", "roles"
  add_foreign_key "users_roles", "users"
end
