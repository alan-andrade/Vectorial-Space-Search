# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101007173511) do

  create_table "answers", :force => true do |t|
    t.integer  "query_id"
    t.integer  "doc_id"
    t.integer  "relevance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "doc_terms", :id => false, :force => true do |t|
    t.integer "doc_id"
    t.integer "term_id"
    t.integer "tf"
  end

  create_table "docs", :force => true do |t|
    t.string "author"
    t.string "title"
    t.string "biblio"
    t.string "excerpt"
    t.text   "content"
  end

  create_table "docs_weights", :force => true do |t|
    t.integer "doc_id"
    t.float   "weight"
  end

  create_table "queries", :force => true do |t|
    t.integer "term_id"
    t.integer "tf"
    t.integer "query_id"
  end

  create_table "query_weights", :force => true do |t|
    t.float   "weight"
    t.integer "query_id"
  end

  create_table "terms", :force => true do |t|
    t.string "term"
    t.float  "idf"
  end

end
