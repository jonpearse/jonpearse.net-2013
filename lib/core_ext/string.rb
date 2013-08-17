# Nice utility class that extends Ruby’s core {String}[http://www.ruby-doc.org/core-1.9.3/String.html] class with some
# useful-ish extras.
#
# Or something
class String
  
  # Returns a normalised version of the string, where all UTF-8/accented/weird characters are converted to their nearest
  # ASCII equivalents. This requires the {Babosa}[https://github.com/norman/babosa] gem to be installed and available.
  def normalize
    to_slug.transliterate.to_s
  end

  # Produces a slugified version of this string safe for use in URLs.
  def slugify
    normalize.gsub(/[^\sa-z0-9\-\_]/i,'').gsub(/\s+/,'-').gsub(/--+/, '-')
  end
  
  # Returns whether or not the string appears to be numeric (ie, is a sequence of numbers possibly starting ‘-’)
  def numeric?
    (self =~ (/\A[+-]?\d+\Z/)) != nil
  end
  
  # Returns whether this string is uncountable or not—ie, whether the plural and singular forms are identical. This is
  # borrowed from Rails core and provided here to be useful.
  def uncountable?
    
    (pluralize == singularize)
    
  end
end