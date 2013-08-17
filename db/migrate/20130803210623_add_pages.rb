class AddPages < ActiveRecord::Migration
  def change
    
    create_table :pages do |t|
      t.string    :title,         :limit => 32
      t.string    :url_slug,      :limit => 64, :null => false
      t.text      :body
      t.text      :body_rendered,               :null => false
      t.datetime  :created_at
      t.datetime  :updated_at
    end
    
    add_index :pages, :url_slug, :unique => true
    
  end
end
