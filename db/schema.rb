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

ActiveRecord::Schema.define(version: 2019_12_24_163948) do

  create_table "attendances", force: :cascade do |t|
    t.string "day"
    t.datetime "work_start_time"
    t.datetime "break_start_time"
    t.datetime "break_end_time"
    t.datetime "work_end_time"
    t.integer "salary"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "shifts", force: :cascade do |t|
    t.date "worked_on"
    t.date "apply_day"
    t.string "request_start_time"
    t.string "request_end_time"
    t.date "approve_day"
    t.string "from_admin_msg"
    t.string "from_staff_msg"
    t.string "start_time"
    t.string "end_time"
    t.boolean "release", default: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_shifts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "tel"
    t.string "email"
    t.boolean "admin", default: false
    t.boolean "kitchen", default: false
    t.boolean "hole", default: false
    t.boolean "wash", default: false
    t.integer "hourly_wage"
    t.string "remember_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
