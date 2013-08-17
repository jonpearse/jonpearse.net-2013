class AddArticles < ActiveRecord::Migration
  def change
    
    # articles table
    create_table :articles do |t|
      t.string    :title,             :limit => 64
      t.string    :url_slug,          :limit => 64,   :null => false
      t.string    :full_url,          :limit => 80,   :null => false
      t.string    :extract,           :limit => 160
      t.string    :extract_rendered,  :limit => 250,  :null => false
      t.text      :body
      t.text      :body_rendered
      t.boolean   :commentable,                       :null => false, :default => true
      t.boolean   :published,                         :null => false, :default => false
      t.datetime  :created_on
      t.datetime  :updated_on
    end
    add_index :articles, :full_url, :unique => true
    add_index :articles, [ :full_url, :published ]
    
    # categories
    create_table :categories do |t|
      t.string    :title,                 :limit => 32
      t.string    :url_slug,              :limit => 32,   :null => false
      t.string    :description,           :limit => 160
      t.string    :description_rendered,  :limit => 250,  :null => false
      t.boolean   :published,                             :null => false, :default => false
      t.datetime  :created_on
    end
    add_index :categories, :url_slug, :unique => true
    
    # link table
    create_table :articles_categories, :id => false do |t|
      t.integer :article_id,  :null => false
      t.integer :category_id, :null => false
    end
  end
end
