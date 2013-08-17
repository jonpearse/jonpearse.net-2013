# Provides view functions used all over the site.
module ApplicationHelper
  
  # Wraps ActionView::Helpers::AssetUrlHelper#image_path and returns an absolute URL to a specific image, including
  # current hostname and protocol.
  #
  # === Parameters
  #
  # [path]  the path to the image we wish to get the URL for
  #
  def image_url( path )
    "#{root_url}#{image_path(path)}".gsub(/([0-9a-z])\/\//, '\1/')
  end
  
  # Wraps ActionView::Helpers::UrlHelper#link_to to produce a link with an additional ‘current’ style if it links to
  # the page currently being viewed. This is useful for navigation sections
  #
  # === Parameters
  #
  # [text]    the text to link
  # [path]    the path to link to
  # [options] an array of additional options—see ActionView::Helpers::UrlHelper#link_to for more information.
  def link_to_with_current( text, path, options = {} )
    # default options
    options[:class] ||= ''
    
    # if we're on the current page, add a 'current' style
    if current_page?(path)
      options[:class] << ' current'
    end
    
    # pass off
    link_to text, path, options
  end
  
  # Convenience function that returns the URL path for the provided article.
  #
  # === Parameters
  #
  # [article]   the Article to generate the path to
  def article_path( article )
    _article_path(:slug => article.full_url)
  end
  
  # Convenience function that returns the URL path for the provided category.
  #
  # === Parameters
  #
  # [article]   the Category to generate the path to
  def category_path( category )
    _category_path(:slug => category.url_slug)
  end
  
  # Formats a date into the form "Mar 5th, 2013"
  #
  # === Parameters
  #
  # [date]  the DateTime object to format
  def form_date( date )
    date.strftime("%b #{date.day.ordinalize}, %Y")
  end
  
  # Goes through text and replaces any dynamic references to Media items with appropriate markup.
  #
  # === Parameters
  #
  # [markup]  the markup to parse
  def process_media( markup )
    
    processed = false
    
    # render images
    markup.gsub!(/\$(?:\&(g|l)t;(!)?:)?media\.(\d+)(?:#(.*?))?\$/) do |m|    
      processed = true
      
      begin
        # load media
        media = Media.find($3)
        
        # locals
        align   = $1.nil? ? 'center' : ($1 == 'l' ? 'left' : 'right')
        caption = $4
        pull    = !$2.nil?
        
        # return code
        render( :partial => "media/#{media.media_type}", :locals => { :media => media, :align => align, :caption => caption, :pull => pull } )
      rescue
        # something went wrong, so return nothing
        ''
      end
    end
    
    # tidy markup…
    if processed
      markup.gsub!(/<p><aside/, '<aside')
      markup.gsub!(/<\/aside>\s?(<\/p>|<br>|<br \/>)/, '</aside>')
    end
    markup
  end
  
  # The exact opposite of #process_media—this goes through markup and removes dynamic references to Media items.
  #
  # === Parameters
  #
  # [markup]  the markup from which to remove Media references
  def remove_media( markup )
    markup.gsub(/\$(?:\&(g|l)t;(!)?:)?media\.(\d+)(?:#(.*?))?\$/, '')
  end
  
end
