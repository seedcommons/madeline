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

ActiveRecord::Schema.define(version: 20160106183814) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "countries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "default_currency_id"
    t.integer "default_language_id"
    t.string "iso_code", limit: 2
    t.integer "language_id"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_index "countries", ["language_id"], name: "index_countries_on_language_id", using: :btree

  create_table "currencies", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "short_symbol"
    t.string "symbol"
    t.datetime "updated_at", null: false
  end

  create_table "division_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
  end

  add_index "division_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "division_anc_desc_idx", unique: true, using: :btree
  add_index "division_hierarchies", ["descendant_id"], name: "division_desc_idx", using: :btree

  create_table "divisions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "currency_id"
    t.text "description"
    t.string "name"
    t.integer "organization_id"
    t.integer "parent_id"
    t.datetime "updated_at", null: false
  end

  add_index "divisions", ["currency_id"], name: "index_divisions_on_currency_id", using: :btree
  add_index "divisions", ["organization_id"], name: "index_divisions_on_organization_id", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at"
    t.string "name"
    t.datetime "updated_at"
  end

  create_table "loans", force: :cascade do |t|
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.integer "currency_id"
    t.integer "division_id"
    t.date "first_interest_payment_date"
    t.date "first_payment_date"
    t.integer "length_months"
    t.integer "loan_type_option_id"
    t.string "name"
    t.integer "organization_id"
    t.integer "organization_snapshot_id"
    t.integer "primary_agent_id"
    t.integer "project_type_option_id"
    t.decimal "projected_return"
    t.integer "public_level_option_id"
    t.decimal "rate"
    t.integer "representative_id"
    t.integer "secondary_agent_id"
    t.date "signing_date"
    t.integer "status_option_id"
    t.date "target_end_date"
    t.datetime "updated_at", null: false
  end

  add_index "loans", ["currency_id"], name: "index_loans_on_currency_id", using: :btree
  add_index "loans", ["division_id"], name: "index_loans_on_division_id", using: :btree
  add_index "loans", ["organization_id"], name: "index_loans_on_organization_id", using: :btree
  add_index "loans", ["organization_snapshot_id"], name: "index_loans_on_organization_snapshot_id", using: :btree

  create_table "media", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "item"
    t.string "item_content_type"
    t.integer "item_file_size"
    t.integer "item_height"
    t.integer "item_width"
    t.string "kind"
    t.integer "media_attachable_id"
    t.string "media_attachable_type"
    t.integer "sort_order"
    t.datetime "updated_at", null: false
  end

  add_index "media", ["media_attachable_type", "media_attachable_id"], name: "index_media_on_media_attachable_type_and_media_attachable_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.integer "notable_id"
    t.string "notable_type"
    t.datetime "updated_at", null: false
  end

  add_index "notes", ["author_id"], name: "index_notes_on_author_id", using: :btree
  add_index "notes", ["notable_type", "notable_id"], name: "index_notes_on_notable_type_and_notable_id", using: :btree

  create_table "organization_snapshots", force: :cascade do |t|
    t.datetime "created_at"
    t.date "date"
    t.integer "environmental_impact_score"
    t.integer "organization_id"
    t.integer "organization_size"
    t.integer "poc_ownership_percent"
    t.datetime "updated_at"
    t.integer "women_ownership_percent"
  end

  add_index "organization_snapshots", ["organization_id"], name: "index_organization_snapshots_on_organization_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string "alias"
    t.string "city"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.integer "division_id"
    t.string "email"
    t.string "fax"
    t.string "industry"
    t.string "last_name"
    t.string "legal_name"
    t.string "name"
    t.string "neighborhood"
    t.text "notes"
    t.integer "organization_snapshot_id"
    t.integer "primary_contact_id"
    t.string "primary_phone"
    t.string "referral_source"
    t.string "secondary_phone"
    t.string "sector"
    t.string "state"
    t.text "street_address"
    t.string "tax_no"
    t.datetime "updated_at", null: false
    t.string "website"
  end

  add_index "organizations", ["division_id"], name: "index_organizations_on_division_id", using: :btree

  create_table "people", force: :cascade do |t|
    t.date "birth_date"
    t.string "city"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.integer "division_id"
    t.string "email"
    t.string "fax"
    t.string "first_name"
    t.string "last_name"
    t.string "legal_name"
    t.string "name"
    t.string "neighborhood"
    t.text "notes"
    t.integer "primary_organization_id"
    t.string "primary_phone"
    t.string "secondary_phone"
    t.string "state"
    t.text "street_address"
    t.string "tax_no"
    t.datetime "updated_at", null: false
    t.string "website"
  end

  add_index "people", ["division_id"], name: "index_people_on_division_id", using: :btree

  create_table "project_logs", force: :cascade do |t|
    t.integer "agent_id"
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "progress_metric_option_id"
    t.integer "project_step_id"
    t.datetime "updated_at", null: false
  end

  add_index "project_logs", ["agent_id"], name: "index_project_logs_on_agent_id", using: :btree
  add_index "project_logs", ["project_step_id"], name: "index_project_logs_on_project_step_id", using: :btree

  create_table "project_steps", force: :cascade do |t|
    t.integer "agent_id"
    t.date "completed_date"
    t.datetime "created_at", null: false
    t.boolean "is_finalized"
    t.integer "project_id"
    t.string "project_type"
    t.date "scheduled_date"
    t.integer "type_option_id"
    t.datetime "updated_at", null: false
  end

  add_index "project_steps", ["agent_id"], name: "index_project_steps_on_agent_id", using: :btree
  add_index "project_steps", ["project_type", "project_id"], name: "index_project_steps_on_project_type_and_project_id", using: :btree

  create_table "translations", force: :cascade do |t|
    t.datetime "created_at"
    t.integer "language_id"
    t.text "text"
    t.string "translatable_attribute"
    t.integer "translatable_id"
    t.string "translatable_type"
    t.datetime "updated_at"
  end

  add_index "translations", ["language_id"], name: "index_translations_on_language_id", using: :btree
  add_index "translations", ["translatable_type", "translatable_id"], name: "index_translations_on_translatable_type_and_translatable_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.inet "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.inet "last_sign_in_ip"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "countries", "currencies", column: "default_currency_id"
  add_foreign_key "countries", "languages"
  add_foreign_key "countries", "languages", column: "default_language_id"
  add_foreign_key "divisions", "currencies"
  add_foreign_key "divisions", "organizations"
  add_foreign_key "loans", "currencies"
  add_foreign_key "loans", "divisions"
  add_foreign_key "loans", "organizations"
  add_foreign_key "loans", "people", column: "primary_agent_id"
  add_foreign_key "loans", "people", column: "representative_id"
  add_foreign_key "loans", "people", column: "secondary_agent_id"
  add_foreign_key "organizations", "countries"
  add_foreign_key "organizations", "divisions"
  add_foreign_key "organizations", "people", column: "primary_contact_id"
  add_foreign_key "people", "countries"
  add_foreign_key "people", "divisions"
  add_foreign_key "people", "organizations", column: "primary_organization_id"
  add_foreign_key "project_logs", "people", column: "agent_id"
  add_foreign_key "project_steps", "people", column: "agent_id"
end
