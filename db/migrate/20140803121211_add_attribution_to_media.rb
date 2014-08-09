class AddAttributionToMedia < ActiveRecord::Migration
  def change
    
    add_column :media, :attribution_text, :string
    add_column :media, :attribution_url,  :string, :limit => 128
    
  end
end
