class Comment < ActiveRecord::Base
  include Errorable, UrlHelper
  
  belongs_to  :article
  belongs_to  :parent,    :class_name => Comment, :foreign_key => :reply_to_id
  has_many    :children,  :class_name => Comment, :foreign_key => :reply_to_id
  
  attr_accessor   :is_human, :save_deets
  attr_accessor   :plain_comment
  
  acts_as_renderable  :fields       => [ :comment ],
                      :restrictions => [ :filter_html, :filter_styles, :filter_classes, :filter_ids, :lite_mode ]
  
  before_comment_render :preprocess_lists
  after_comment_render  :postprocess_lists, :process_blockquote
  before_save           :process_urls
  after_save            :update_article
  after_destroy         :update_article
  
  validates :name, :email, :comment, :presence => true
  validates :name, :length => { :maximum => 32 }
  validates :email, 
            :length => { :maximum => 64 }, 
            :format => { :with => /[a-z0-9!\#\$%&'*\+\/=\?\^_`\{\|\}~\-]+(?:\.[a-z0-9!\#\$%&'\*\+\/=\?\^_`\{\|\}~\-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/ }
  validates :website,
            :length => { :maximum => 64 },
            :allow_blank => true
#            :format => { :with => /\A(?:(?:https?):\/\/)?(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\x00a1-\xffff0-9]+-?)*[a-z\x00a1-\xffff0-9]+)(?:\.(?:[a-z\x00a1-\xffff0-9]+-?)*[a-z\x00a1-\xffff0-9]+)*(?:\.(?:[a-z\x00a1-\xffff]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?\Z/ }
  validates :is_human, :acceptance => { :message => 'You must check this box to submit your comment' }
  
  scope :viewable,  -> { where("(comments.screened = 0)").order('comments.created_at ASC') }
  scope :latest,    -> { where('(comments.screened = 0)').order('comments.created_at DESC') }
  scope :popular,   -> { joins("LEFT JOIN comments AS r ON (r.reply_to_id = comments.id)").group('comments.id').order("count(r.id) DESC") }
  
  private
    def preprocess_lists
      
      # store unmolested comment
      self.plain_comment = comment
      
      # molest the comment
      self.comment = comment.gsub("\r", '').gsub(/^(([\*#]+)\s+(.*?)\n)+/) { |match| preprocess_lists_parse(match)+"\n" }

    end
    
    def postprocess_lists
      
      # replace markers with markup in rendered version
      self.comment_rendered = comment_rendered.gsub('<p>\uF8F0', '\uF8F0').gsub('\uF8F0</p>', '\uF8F0').
                                               gsub('\uF8F1\uF8F0', "</li>\n</ul>\n").gsub('\uF8F2\uF8F0', "</li>\n</ol>\n").
                                               gsub('\uF8F0\uF8F1', "<ul>\n<li>").gsub('\uF8F0\uF8F2', "<ol>\n<li>").
                                               gsub('\uF8F3', "</li>\n<li>")

      # restore unmolested comment
      self.comment = self.plain_comment                                     
      
    end
    
    def process_blockquote
      
      self.comment_rendered = comment_rendered.gsub(/<p>&gt;(.*?)<\/p>/m) do |match|

        # remove quote lines
        match = match.gsub(/(<p>|\n)&gt;\s*/, '\1')
        
        # replace multiple newlines with paras
        match = match.gsub(/<br>\n(<br>\n)+/, "</p>\n\n<p>")
                
        # wrap everything up
        cite_url = article_comments_path(self.article, self.reply_to_id)
        "<blockquote cite=\"http://jonpearse.net#{cite_url}\" data-comment-id=\"#{self.reply_to_id}\">#{match}</blockquote>"
        
      end      
    end
    
    def preprocess_lists_parse( block )
      
      # 1. grab the first bullet (either * or #)
      bullet = block[0]
      lines = block.split("\n")
      
      # 2. check
      block_match = true
      lines.map! do |line|
        if line[0] != bullet
          block_match = false
        end
        
        line.gsub(/^(\*|#)\s*/, '')
      end
      
      # 3. if it didn't work, drop out
      if !block_match
        return block
      end
      
      # 4. in which case, stick a marker, and recurse
      marker = (bullet == '*') ? '\uF8F1' : '\uF8F2'
      output = '\uF8F0'+marker+lines.join("\n").gsub(/^(([\*#]+)\s+(.*?)(\n|$))+/) { |match| preprocess_lists_parse(match)+"\n" }+marker+'\uF8F0'
      
      # 5. output, in an unmungeable way      
      output.gsub("\n", '\uF8F3').gsub('\uF8F3\uF8F0', '\uF8F0').gsub('\uF8F3'+marker, marker)
    end
    
    def process_urls
      
      # process website
      self.website = "http://#{website}" unless website.nil? or website.match(/^http(s)?:\/\//)
      
      # process comments
      self.comment_rendered = comment_rendered.gsub(/<a\s*href="([^"]+)">/) do |link|
        
        url = $1
        bits = url.split(/\/+/)
        
        if (bits.size == 1) or (bits[0].match('.'))
          "<a href=\"http://#{url}\" rel=\"external\">"
        else
          link
        end
      end
      
    end
  
    def update_article
      
      self.article.count_comments!
      
    end
end