class AddMetaToMedia < ActiveRecord::Migration
  def change

    add_column :media, :file_meta, :string
    
  end
end
