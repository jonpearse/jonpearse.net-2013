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

ActiveRecord::Schema.define(version: 20140809184820) do

  create_table "articles", force: true do |t|
    t.string   "title",            limit: 64
    t.string   "url_slug",         limit: 64,                   null: false
    t.string   "full_url",         limit: 80,                   null: false
    t.string   "extract",          limit: 160
    t.string   "extract_rendered", limit: 250,                  null: false
    t.text     "body"
    t.text     "body_rendered"
    t.boolean  "commentable",                   default: true,  null: false
    t.boolean  "published",                     default: false, null: false
    t.datetime "created_on"
    t.datetime "updated_on"
    t.date     "published_on"
    t.integer  "masthead_id"
    t.string   "teaser",           limit: 1024
    t.string   "teaser_rendered",  limit: 1024
    t.integer  "num_comments",                  default: 0
  end

  add_index "articles", ["full_url", "published"], name: "index_articles_on_full_url_and_published", using: :btree
  add_index "articles", ["full_url"], name: "index_articles_on_full_url", unique: true, using: :btree
  add_index "articles", ["published", "published_on"], name: "published", using: :btree

  create_table "articles_categories", id: false, force: true do |t|
    t.integer "article_id",  null: false
    t.integer "category_id", null: false
  end

  create_table "categories", force: true do |t|
    t.string   "title",                limit: 32
    t.string   "url_slug",             limit: 32,                  null: false
    t.string   "description",          limit: 160
    t.string   "description_rendered", limit: 250,                 null: false
    t.boolean  "published",                        default: false, null: false
    t.datetime "created_on"
  end

  add_index "categories", ["url_slug"], name: "index_categories_on_url_slug", unique: true, using: :btree

  create_table "comments", force: true do |t|
    t.integer  "article_id"
    t.integer  "reply_to_id"
    t.boolean  "screened",                    default: false, null: false
    t.string   "name",             limit: 32,                 null: false
    t.string   "email",            limit: 64,                 null: false
    t.string   "website",          limit: 64
    t.text     "comment"
    t.text     "comment_rendered"
    t.string   "ip",               limit: 15
    t.datetime "created_at"
  end

  add_index "comments", ["article_id", "reply_to_id"], name: "index_comments_on_article_id_and_reply_to_id", using: :btree

  create_table "galleries", force: true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "description_rendered"
    t.datetime "created_at"
    t.datetime "udpated_at"
    t.string   "cached_heights",       limit: 64
  end

  create_table "galleries_media", id: false, force: true do |t|
    t.integer "gallery_id"
    t.integer "media_id"
    t.integer "display_order", default: 0
  end

  add_index "galleries_media", ["gallery_id", "media_id"], name: "index_galleries_media_on_gallery_id_and_media_id", unique: true, using: :btree

  create_table "media", force: true do |t|
    t.string   "title",                  limit: 64
    t.string   "alt_text",               limit: 160, null: false
    t.string   "title_text"
    t.string   "media_type",             limit: 16
    t.string   "default_align",          limit: 16
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "attribution_text"
    t.string   "attribution_url",        limit: 128
    t.string   "file_meta"
    t.integer  "attribution_license_id"
  end

  create_table "media_licenses", force: true do |t|
    t.string "title", limit: 64
    t.string "icon",  limit: 32
  end

  create_table "pages", force: true do |t|
    t.string   "title",         limit: 32
    t.string   "url_slug",      limit: 64, null: false
    t.text     "body"
    t.text     "body_rendered",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "masthead_id"
  end

  add_index "pages", ["url_slug"], name: "index_pages_on_url_slug", unique: true, using: :btree

  create_table "previews", force: true do |t|
    t.integer  "user_id"
    t.string   "model_name", limit: 16, null: false
    t.text     "model_data"
    t.datetime "created_on"
  end

  add_index "previews", ["user_id", "model_name"], name: "index_previews_on_user_id_and_model_name", using: :btree

  create_table "users", force: true do |t|
    t.string   "username",                               null: false
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "gauth_secret"
    t.string   "gauth_enabled",          default: "f"
    t.string   "gauth_tmp"
    t.datetime "gauth_tmp_datetime"
    t.boolean  "updated",                default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
