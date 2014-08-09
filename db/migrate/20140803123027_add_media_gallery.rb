class AddMediaGallery < ActiveRecord::Migration
  def change
    
    create_table  :galleries do |t|
      t.string      :title
      t.renderable  :description
      t.datetime    :created_at
      t.datetime    :udpated_at
    end
    
    create_table  :galleries_media, :id => false do |t|
      t.integer :gallery_id
      t.integer :media_id
    end
    
    add_index :galleries_media, [:gallery_id, :media_id], :unique => true
    
  end
end
