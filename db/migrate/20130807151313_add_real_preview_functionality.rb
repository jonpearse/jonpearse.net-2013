class AddRealPreviewFunctionality < ActiveRecord::Migration
  def change
    
    create_table :previews do |t|
      t.integer   :user_id
      t.string    :model_name,  :limit => 16, :null => false
      t.text      :model_data
      t.datetime  :created_on
    end
    
    add_index :previews, [ :user_id, :model_name ]
    
  end
end
