# Allows CRUD-type management of {categories}[rdoc-ref:Category] on the site. See ContentController for further information.
class Admin::CategoriesController < Admin::ContentController
  
  def initialize
    super
    self.content_object       = Category
    self.default_sort_column  = 'title'
    self.allow_create         = true
    
    @current_section = 'blog'
  end
  
end