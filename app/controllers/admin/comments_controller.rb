# Allows CRUD-type management of {comments}[rdoc-ref:Comment] on the site. See ContentController for further information.
class Admin::CommentsController < Admin::ContentController
  
  def initialize
    super
    self.content_object       = Comment
    self.allow_create         = true
    
    @current_section = 'blog'
  end
  
  def index
        
    @article = Article.find(params[:id])
    @comments = @article.comments.where('reply_to_id IS NULL').order('created_at DESC')
    
  rescue
    
    not_found and return
    
  end
  
  def screen
    begin
      @comment = Comment.find(params[:id])
      @comment.update_attribute(:screened, params[:state])
      @comment.article.count_comments!
    rescue
    end
    
    respond_to do |format|
      format.html { redirect_to admin_root_path and return }
      format.js
    end
  end
  
  # Destroys (unpersists) the content with the given ID. This has no checking and assumes that you meant to do it…
  #
  # === Expected parameters
  #
  # [id]  the ID of the Article to publish
  def destroy
    @content = Comment.find(params[:id])
    @content.destroy
    flash[:notice] = t(:deleted)
    
    @content.article.count_comments!
    
    respond_to do |format|
      format.html { redirect_to admin_root_path and return }
      format.js
    end
  end
  
  protected
    def after_update c
    
      if params.key?('home')
        admin_root_path
      end
    
      super      
    end
end