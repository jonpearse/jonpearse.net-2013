# This represents a (blog) article within the site.
class Article < ActiveRecord::Base
  include Errorable
  
  # relations
  has_and_belongs_to_many :categories
  belongs_to              :masthead, :foreign_key => :masthead_id, :class_name => Media
  
  # accessible stuff
  attr_accessible :title, :commentable, :published, :url_slug, :category_ids, :published_on, :masthead_id
  
  # hooks
  acts_as_renderable  :fields => [ :extract, :body, :teaser ]
  before_validation   :set_pub_date, :generate_slug, :generate_teaser
  after_render        :clean_teaser_split
  
  # validation
  validates :title, :body, :extract, :url_slug, :presence => true
  validates :extract,   :length => { :maximum => 160 }
  validates :url_slug,  :length => { :maximum => 64 }
  validates :full_url,  :length => { :maximum => 80 },
                        :uniqueness => true
  
  class << self
    
    # Loads an archive for all published articles on the site. This returns a Hash, each member of which is itself a
    # Hash representing a year. The individual hashes then contain a key for each month where articles were published,
    # where the value is the number of articles published in that month.
    # In addition, each year hash contains a member called @:_total@ that contains the total number of articles published
    # in that year.
    #
    # In other words:
    #   {
    #     2012 => {
    #       10 => 1,
    #       11 => 2,
    #       12 => 5
    #       :_total => 8
    #     },
    #     2013 => {
    #       1 => 4,
    #       3 => 2,     # note: no articles in February
    #       4 => 5,
    #       :_total => 11
    #   }
    def load_archive
      # grab counts for individual months
      query = "SELECT year(published_on) AS the_year, month(published_on) AS the_month, count(*) AS total "+
              "FROM articles WHERE published=1 GROUP BY the_year, the_month ORDER BY published_on DESC"
      months = ActiveRecord::Base.connection.exec_query(query)
      
      # rotate around year/month
      to_return = {}
      months.each do |month|
        
        y = month['the_year'].to_i
        
        unless to_return.key?(month['the_year'])
          to_return[y] = { :_total => 0 }
        end
        
        to_return[y][:_total] += month['total']
        to_return[y][month['the_month'].to_i] = month['total']
      end
        
      to_return
    end
  end
  
  # Publishes this article. This sets the @:published@ flag to true, and the value of the DateTime field @published_on@
  # to the current time.
  def publish!
    self.update_attributes(
      :published    => true,
      :published_on => DateTime.now
    )
  end
  
  private
    def set_pub_date

      if published and published_on.nil?
        self.published_on = DateTime.now
      end
      
    end
  
    def generate_slug
      
      # 1. generate a URL slug if we have one
      if (url_slug.nil? or url_slug.empty?) and !title.empty?
        
        # generate slug
        slug = title.downcase.slugify
        
        # lookup conditions
        cond = [ 'url_slug = ?', slug ]
        if persisted?
          cond[0] << ' AND id != ?'
          cond << id
        end
        
        # enforce uniqueness
        i = 2
        suff = ''
        until Article.all(:conditions => cond).empty? do
          # append numbers
          suff = "-#{i}"
          cond[1] = slug+suff
          i += 1
        end
        
        # save
        self.url_slug = slug+suff    
      end
            
      # 2. generate full path
      self.full_url = (published? ? published_on : DateTime.now).strftime('%Y/%m/')+self.url_slug

    end  

    # @TODO: add a switch to manually inhibit updating the teaser
    def generate_teaser
        
      # Chop body on triple-equals if present
      bits = body.split(/\n===\s+\n/, 2)
      self.teaser = bits.length == 1 ? nil : bits[0]
      
    end
    
    def clean_teaser_split
      
      self.body_rendered = body_rendered.gsub /<p>===<\/p>\n?/, ''
      
    end
end