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

ActiveRecord::Schema.define(version: 2019_04_14_203135) do

  create_table "scraper_jobs", force: :cascade do |t|
    t.string "url", null: false
    t.integer "story_id"
    t.integer "scrape_status", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["url"], name: "index_scraper_jobs_on_url", unique: true
  end

  create_table "stories", force: :cascade do |t|
    t.string "canonical_url", null: false
    t.string "ogp_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["canonical_url"], name: "index_stories_on_canonical_url", unique: true
  end

end
