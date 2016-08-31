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

ActiveRecord::Schema.define(version: 20160830175706) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
    t.string   "slug"
    t.index ["slug"], name: "index_categories_on_slug", unique: true, using: :btree
  end

  create_table "categories_events", id: false, force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "event_id",    null: false
    t.index ["category_id", "event_id"], name: "index_categories_events_on_category_id_and_event_id", using: :btree
    t.index ["event_id", "category_id"], name: "index_categories_events_on_event_id_and_category_id", using: :btree
  end

  create_table "event_pictures", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "sort_index",         default: 100
    t.string   "media_file_name"
    t.string   "media_content_type"
    t.integer  "media_file_size"
    t.datetime "media_updated_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["event_id"], name: "index_event_pictures_on_event_id", using: :btree
  end

  create_table "events", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.text     "instruction"
    t.string   "location_name"
    t.string   "location_address"
    t.decimal  "latitude",         precision: 10, scale: 6
    t.decimal  "longitude",        precision: 10, scale: 6
    t.datetime "uptime"
    t.integer  "max_price"
    t.integer  "min_price"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "slug"
    t.string   "name"
    t.index ["slug"], name: "index_events_on_slug", unique: true, using: :btree
    t.index ["user_id"], name: "index_events_on_user_id", using: :btree
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "event_id"
    t.string   "invoice_no"
    t.string   "status"
    t.string   "code"
    t.string   "qr_code_file_name"
    t.string   "qr_code_content_type"
    t.integer  "qr_code_file_size"
    t.datetime "qr_code_updated_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["event_id"], name: "index_orders_on_event_id", using: :btree
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "payments", force: :cascade do |t|
    t.string   "status"
    t.string   "methods"
    t.string   "omise_transaction_id"
    t.integer  "amount"
    t.integer  "fee"
    t.string   "slip_file_name"
    t.string   "slip_content_type"
    t.integer  "slip_file_size"
    t.datetime "slip_updated_at"
    t.datetime "approved_at"
    t.datetime "paid_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "order_id"
    t.index ["order_id"], name: "index_payments_on_order_id", using: :btree
  end

  create_table "sections", force: :cascade do |t|
    t.string   "status"
    t.integer  "event_id"
    t.string   "title"
    t.datetime "event_time"
    t.datetime "end_time"
    t.integer  "price"
    t.integer  "total",      default: 0
    t.integer  "bought",     default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["event_id"], name: "index_sections_on_event_id", using: :btree
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_taggings_on_event_id", using: :btree
    t.index ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_tags_on_title", unique: true, using: :btree
  end

  create_table "tickets", force: :cascade do |t|
    t.string   "status"
    t.string   "code"
    t.string   "qr_code_file_name"
    t.string   "qr_code_content_type"
    t.integer  "qr_code_file_size"
    t.datetime "qr_code_updated_at"
    t.integer  "user_id"
    t.integer  "event_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "section_id"
    t.integer  "order_id"
    t.index ["event_id"], name: "index_tickets_on_event_id", using: :btree
    t.index ["order_id"], name: "index_tickets_on_order_id", using: :btree
    t.index ["section_id"], name: "index_tickets_on_section_id", using: :btree
    t.index ["user_id"], name: "index_tickets_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.date     "birthday"
    t.string   "phone"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
    t.string   "role"
    t.string   "provider"
    t.string   "uid"
    t.string   "access_token"
    t.string   "omise_customer_id"
    t.string   "onesignal_id"
    t.string   "company"
    t.string   "url"
    t.string   "interest"
    t.text     "short_description"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "referal_code"
    t.integer  "referrer_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["referrer_id"], name: "index_users_on_referrer_id", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

  create_table "wishlists", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_wishlists_on_event_id", using: :btree
    t.index ["user_id"], name: "index_wishlists_on_user_id", using: :btree
  end

  add_foreign_key "event_pictures", "events"
  add_foreign_key "events", "users"
  add_foreign_key "orders", "events"
  add_foreign_key "orders", "users"
  add_foreign_key "payments", "orders"
  add_foreign_key "sections", "events"
  add_foreign_key "taggings", "events"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tickets", "events"
  add_foreign_key "tickets", "orders"
  add_foreign_key "tickets", "sections"
  add_foreign_key "tickets", "users"
  add_foreign_key "wishlists", "events"
  add_foreign_key "wishlists", "users"
end
