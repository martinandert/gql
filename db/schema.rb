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

ActiveRecord::Schema.define(version: 20150310163512) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "albums", force: :cascade do |t|
    t.string  "slug",        null: false
    t.integer "band_id",     null: false
    t.string  "title",       null: false
    t.date    "released_on", null: false
  end

  add_index "albums", ["band_id", "released_on"], name: "index_albums_on_band_id_and_released_on", using: :btree
  add_index "albums", ["band_id"], name: "index_albums_on_band_id", using: :btree
  add_index "albums", ["released_on"], name: "index_albums_on_released_on", using: :btree
  add_index "albums", ["slug"], name: "index_albums_on_slug", unique: true, using: :btree

  create_table "attributions", force: :cascade do |t|
    t.integer "song_id",   null: false
    t.integer "writer_id", null: false
  end

  add_index "attributions", ["song_id", "writer_id"], name: "index_attributions_on_song_id_and_writer_id", unique: true, using: :btree

  create_table "bands", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
  end

  add_index "bands", ["slug"], name: "index_bands_on_slug", unique: true, using: :btree

  create_table "membership_roles", force: :cascade do |t|
    t.integer "membership_id", null: false
    t.integer "role_id",       null: false
  end

  add_index "membership_roles", ["membership_id", "role_id"], name: "index_membership_roles_on_membership_id_and_role_id", unique: true, using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer "band_id",      null: false
    t.integer "member_id",    null: false
    t.integer "started_year", null: false
    t.integer "ended_year"
  end

  add_index "memberships", ["band_id", "member_id"], name: "index_memberships_on_band_id_and_member_id", unique: true, using: :btree

  create_table "people", force: :cascade do |t|
    t.string "slug",       null: false
    t.string "first_name", null: false
    t.string "last_name",  null: false
  end

  add_index "people", ["slug"], name: "index_people_on_slug", unique: true, using: :btree

  create_table "roles", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
  end

  add_index "roles", ["name"], name: "index_roles_on_name", unique: true, using: :btree
  add_index "roles", ["slug"], name: "index_roles_on_slug", unique: true, using: :btree

  create_table "songs", force: :cascade do |t|
    t.string  "slug",         null: false
    t.integer "album_id",     null: false
    t.string  "title",        null: false
    t.integer "duration",     null: false
    t.integer "track_number", null: false
    t.text    "note"
  end

  add_index "songs", ["album_id", "track_number"], name: "index_songs_on_album_id_and_track_number", unique: true, using: :btree
  add_index "songs", ["album_id"], name: "index_songs_on_album_id", using: :btree
  add_index "songs", ["slug"], name: "index_songs_on_slug", unique: true, using: :btree
  add_index "songs", ["track_number"], name: "index_songs_on_track_number", using: :btree

end
