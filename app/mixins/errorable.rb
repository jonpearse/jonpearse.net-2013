# This hooks into ActiveRecord::Base and provides a slightly simpler way of accessing Rails’ default error
# messages/handling. 
#
# I may get around to turning into a gem at some point, but this works well enough for now.
module Errorable
  
  # Returns whether or not there is an error associated with the provided property
  def has_error?( property )
    self.errors[property].present?
  end
  
  # View helper method that returns ‘error’ if there’s a validation error associated with the provided property.
  def error_class( property )
    self.has_error?(property) ? 'error' : nil
  end
  
  # Utility function that concatenates all available validation error messages for the provided property.
  def error_messages( property )
    unless self.has_error? property
      return nil
    end
    
    ret = ''
    idx = 0
    self.errors[property].each do |msg|
      ret << ((idx == 0) ? msg : ", " + msg[0].downcase + msg[1..-1])
      idx += 1
    end
    
    ret
  end
end