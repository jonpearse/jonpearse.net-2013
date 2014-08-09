class AddLicenseToMedia < ActiveRecord::Migration
  def change
    
    create_table :media_licenses do |t|
      t.string  :title, :limit => 64
      t.string  :icon,  :limit => 32
    end
    
    add_column  :media, :attribution_license_id,  :integer
    
  end
end
