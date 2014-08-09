# Allows CRUD-type management of {articles}[rdoc-ref:Article] on the site. See ContentController for further information.
class Admin::ArticlesController < Admin::ContentController
  
  def initialize
    super
    self.content_object       = Article
    self.allow_create         = true
    
    @current_section = 'blog'
  end
  
  # Publishes the Article with the provided ID. Complementary method to #unpublish
  #
  # === Expected parameters
  #
  # [id]  the ID of the Article to publish
  def publish
    
    begin
      Article.find(params[:id]).publish!
    rescue
    end
    
    if params.key?('home')
      respond_to do |format|
        format.html { redirect_to admin_root_path and return }
        format.js
      end
    else
      redirect_to admin_articles_path and return
    end
    
  end
  
  # Unpublishes the Article with the provided ID. Complementary method to #publish.
  #
  # === Expected parameters
  #
  # [id]  the ID of the Article to publish
  def unpublish
    begin
      Article.find(params[:id]).update_attribute(:published, 0)
    rescue
    end
    
    if params.key?('home')
      respond_to do |format|
        format.html { redirect_to admin_root_path and return }
        format.js
      end
    else
      redirect_to admin_articles_path and return
    end
  end
  
  def additional_params
    [ :category_ids => [] ]
  end
  
  protected
    def search_clause
      [ '(title LIKE ?) OR (extract LIKE ?)', "%#{params['q']}%", "%#{params['q']}%" ]
    end
  
    def after_destroy c
      
      if params.key?('home')
        admin_root_path
      end
      
      super      
    end
end