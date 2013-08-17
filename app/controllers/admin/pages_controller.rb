# Allows CRUD-type management of {pages}[rdoc-ref:Page] on the site. See ContentController for further information.
class Admin::PagesController < Admin::ContentController
  
  def initialize
    super
    self.content_object       = Page
    self.default_sort_column  = 'title'
    self.allow_create         = true
  end
  
end