class AddHeightsToGalleries < ActiveRecord::Migration
  def change
    
    add_column  :galleries, :cached_heights, :string, :limit => 64
    
  end
end
