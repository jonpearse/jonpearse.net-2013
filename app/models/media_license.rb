class MediaLicense < ActiveRecord::Base
  
  # relations
  has_many  :media, :foreign_key => :attribution_license_id
  
end