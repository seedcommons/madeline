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

ActiveRecord::Schema.define(version: 20151231180615) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "currencies", force: :cascade do |t|
    t.string   "code"
    t.string   "symbol"
    t.string   "short_symbol"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "division_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id",   null: false
    t.integer "descendant_id", null: false
    t.integer "generations",   null: false
  end

  add_index "division_hierarchies", ["ancestor_id", "descendant_id", "generations"], name: "division_anc_desc_idx", unique: true, using: :btree
  add_index "division_hierarchies", ["descendant_id"], name: "division_desc_idx", using: :btree

  create_table "divisions", force: :cascade do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.text     "description"
    t.integer  "parent_id"
    t.integer  "currency_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "divisions", ["currency_id"], name: "index_divisions_on_currency_id", using: :btree
  add_index "divisions", ["organization_id"], name: "index_divisions_on_organization_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "display_name"
    t.string   "sector"
    t.string   "industry"
    t.string   "referral_source"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "people", force: :cascade do |t|
    t.string   "name"
    t.integer  "primary_organization_id"
    t.date     "birth_date"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "divisions", "currencies"
  add_foreign_key "divisions", "organizations"
  add_foreign_key "people", "organizations", column: "primary_organization_id"
end
