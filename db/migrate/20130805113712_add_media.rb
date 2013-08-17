class AddMedia < ActiveRecord::Migration
  def up
    
    create_table :media do |t|
      t.string    :title,         :limit => 64
      t.string    :alt_text,      :limit => 160,  :null => false
      t.string    :title_text,    :limit => 255
      t.string    :media_type,    :limit => 16
      t.string    :default_align, :limit => 16
      t.datetime  :created_on
      t.datetime  :updated_on
    end
    
    add_attachment :media, :file
    
  end

  def down
    
    drop_table :media
    
  end
end
