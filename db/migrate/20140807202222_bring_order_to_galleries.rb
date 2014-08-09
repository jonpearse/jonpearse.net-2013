class BringOrderToGalleries < ActiveRecord::Migration
  def change
    
    add_column :galleries_media, :display_order, :integer, :default => 0
    
  end
end
