class AddCommenting < ActiveRecord::Migration
  def change

    create_table :comments do |t|
      t.integer     :article_id
      t.integer     :reply_to_id
      t.boolean     :screened,                    :null => false, :default => false
      t.string      :name,          :limit => 32, :null => false
      t.string      :email,         :limit => 64, :null => false
      t.string      :website,       :limit => 64
      t.renderable  :comment, :text
      t.string      :ip,            :limit => 15
      t.datetime    :created_at
    end
        
    add_index :comments, [ :article_id, :reply_to_id ]
    
    add_column  :articles, :num_comments, :integer, :default => 0

  end
end
