# Monkey-patch of ActiveRecord::Base that converts empty string values to @nil@ when saving to the database.
#
# Adapted from http://www.keenertech.com/articles/2011/06/11/the-empty-string-code-smell-in-rails
class ActiveRecord::Base
  
  #def write_attribute(attr_name, value)
  #   new_value = value.presence
  #   super(attr_name, new_value)
  #end
  
end