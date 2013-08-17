class AddMediaToArticlesAndPages < ActiveRecord::Migration
  def change
    
    add_column :articles, :masthead_id, :integer
    add_column :pages,    :masthead_id, :integer
    
  end
end
