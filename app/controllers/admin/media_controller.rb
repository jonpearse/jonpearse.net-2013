# Allows CRUD-type management of {media}[rdoc-ref:Media] on the site. See ContentController for further information.
class Admin::MediaController < Admin::ContentController
  
  def initialize
    super
    self.content_object = Media
    self.allow_create   = true
    self.choose_view    = 'list'
  end
  
  def additional_params
    [ :file ]
  end
    
  protected    
    def search_clause
      [ 'title LIKE ?', "%#{params['q']}%" ]
    end
    
    def choose_clause( conditions )
      
      if params.key?('type')
        conditions[0] << ' AND media_type = ?'
        conditions << params[:type]
      end
      
      if params.key?('excl')
        conditions[0] << ' AND media_type != ?'
        conditions << params[:excl]
      end
      
    end
end