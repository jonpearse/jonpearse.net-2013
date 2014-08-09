# Represents a gallery of {media}[rdoc-ref:Media] items that can be embedded on the site.
class Gallery < ActiveRecord::Base
  include Errorable
  
  # relations
  has_and_belongs_to_many :media, -> { order "display_order ASC" }
  
  # accessors
  attr_accessor :heights
  
  # hooks
  after_find  :parse_heights
  before_save :cache_heights
  after_save  :store_order
  
  # validations
  validates :title, :presence => true
  
  # intercept for setting media IDs
  def media_ids=( ids )
    
    # call up
    super
    
    # store
    @stored_ids = ids
    
  end
  
  private
    # Helper function that caches the minimum height of the gallery for each thumbnail size on save. This avoids having
    # to dynamically recalculate the height in JS on the front-end, as that leads to a whole world of pain and
    # race-conditions… and nobody wants that.  
    def cache_heights
            
      # build empty array
      mins = {}
      Media::TYPES[:responsive].each_key { |size| mins[size.to_sym] = [] }
      
      # get heights of each image for each size
      media.each do |m|  
        mins.each_key { |size| mins[size].push m.file.height( size ) }
      end
      
      # now reduce
      self.cached_heights = mins.each_pair { |size,set| mins[size] = set.min  }
            
    end
    
    # Cheeky after_find hook that parses the cached heights (stored as YAML in the DB) and turns them back into a hash
    # we can use.
    def parse_heights
      
      begin
        @heights = YAML.load cached_heights
      rescue
      end
      
    end
    
    # Cheaty callback that stores the order of the gallery without having to use a link object
    def store_order
      
      @stored_ids.each_index do |idx|
        
        ActiveRecord::Base.connection.execute "UPDATE galleries_media SET display_order=#{idx} WHERE gallery_id=#{id} AND media_id=#{@stored_ids[idx]}"
        
      end
      
    end
  
end