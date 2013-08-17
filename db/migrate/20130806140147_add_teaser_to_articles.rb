class AddTeaserToArticles < ActiveRecord::Migration
  def change
    
    add_column :articles, :teaser,          :string, :limit => 1024
    add_column :articles, :teaser_rendered, :string, :limit => 1024
    
  end
end
