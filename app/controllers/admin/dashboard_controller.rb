# This is the ‘home’ controller for the {Admin}[rdoc-ref:Admin] namespace.
class Admin::DashboardController < Admin::AdminController
  
  # Produces the admin homepage. Most of the work here is in the view layer…
  def index
  end
  
  # Returns a list of the five most recently-published {articles}[rdoc-ref:Article].
  def latest_articles
    @articles = Article.where(:published => true).order('created_on DESC').limit(5)
    
    render :layout => nil
  end
  
  # Returns a list of the five most recently-written unpublished {articles}[rdoc-ref:Article]
  def drafts
    @articles = Article.where(:published => false).order('created_on DESC').limit(5)
    
    render :layout => nil
  end
  
  # Returns a list of the five most recently-written {comments}[rdoc-ref:Comment]
  def comments
    @comments = Comment.order('created_at DESC').limit(5)
    
    render :layout => nil
  end
  
end