# Allows CRUD-type management of {media galleries}[rdoc-ref:Gallery] on the site. See ContentController for further 
# information.
class Admin::GalleriesController < Admin::ContentController
  
  def initialize
    super
    self.content_object       = Gallery
    self.allow_create         = true
  end
  
  def additional_params
    [ :media_ids => [] ]
  end
  
  protected    
    def search_clause
      [ 'title LIKE ?', "%#{params['q']}%" ]
    end
end