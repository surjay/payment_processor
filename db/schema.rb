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

ActiveRecord::Schema.define(version: 2022_09_11_193412) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "merchants", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_merchants_on_name"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.bigint "merchant_id"
    t.integer "method_type", default: 0, null: false
    t.jsonb "data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "default", default: false
    t.index ["merchant_id"], name: "index_payment_methods_on_merchant_id"
    t.index ["method_type"], name: "index_payment_methods_on_method_type"
  end

  create_table "payouts", force: :cascade do |t|
    t.bigint "merchant_id"
    t.integer "transaction_ids", default: [], array: true
    t.decimal "total", precision: 20, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_payouts_on_merchant_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "merchant_id"
    t.bigint "payment_method_id"
    t.bigint "to_merchant_id"
    t.integer "scheduled_type", default: 0
    t.integer "status", default: 0
    t.date "scheduled_date"
    t.decimal "amount", precision: 20, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchant_id"], name: "index_transactions_on_merchant_id"
    t.index ["payment_method_id"], name: "index_transactions_on_payment_method_id"
    t.index ["scheduled_date"], name: "index_transactions_on_scheduled_date"
    t.index ["scheduled_type", "scheduled_date", "status"], name: "index_transactions_on_type_and_date_and_status"
    t.index ["scheduled_type"], name: "index_transactions_on_scheduled_type"
    t.index ["status"], name: "index_transactions_on_status"
    t.index ["to_merchant_id"], name: "index_transactions_on_to_merchant_id"
  end

  add_foreign_key "payment_methods", "merchants"
  add_foreign_key "payouts", "merchants"
  add_foreign_key "transactions", "merchants"
  add_foreign_key "transactions", "merchants", column: "to_merchant_id"
  add_foreign_key "transactions", "payment_methods"
end
