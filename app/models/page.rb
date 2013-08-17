# Represents a static page in the system.
class Page < ActiveRecord::Base
  include Errorable
  
  # relations
  belongs_to              :masthead, :foreign_key => :masthead_id, :class_name => Media
  
  # accessible stuff
  attr_accessible :title, :url_slug, :masthead_id
  
  # hooks
  acts_as_renderable :fields => [ :body ]
  before_validation :generate_slug
  
  # validations
  validates :title, :body, :presence => true 
  validates :url_slug,  :presence => true,
                        :uniqueness => true,
                        :length => { :in => 2..64 },
                        :format => { :with => /^(?!(articles))/ }
  
  private
    def generate_slug
      
      if url_slug.nil? or url_slug.empty?
        
        # generate slug
        self.url_slug = title.downcase.slugify
        
      elsif url_slug.starts_with? '/'
        
        # we have a leading slash, so trim        
        self.url_slug = url_slug[1..-1]
        
      end
    end
  
end