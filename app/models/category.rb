# This represents a (blog) category within the system—{articles}[rdoc-ref:Article] can exist in many categories,
# and categories can have many articles.
class Category < ActiveRecord::Base
  include Errorable
  
  # relations
  has_and_belongs_to_many :articles
  
  # accessible attributes
  attr_accessible :title, :published, :url_slug
  
  # hooks
  acts_as_renderable :fields => [ :description ]
  before_validation :generate_slug
  
  # validation
  validates :title, :description, :url_slug, :presence => true 
  validates :url_slug, :uniqueness => true,
                       :length => { :in => 2..32 }
  
  private
    def generate_slug
      
      if url_slug.nil? or url_slug.empty?
        
        # generate slug
        slug = title.downcase.slugify
                
        # save
        self.url_slug = slug
      end
      
    end
end