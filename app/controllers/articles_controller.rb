# Provides majority of front-end functionality surrounding {articles}[rdoc-ref:Article] on the site.
class ArticlesController < ApplicationController
  
  # Renders the five most-recent published {articles}[rdoc-ref:Article] in the system.
  #
  # This is also the default root for the site.
  def index
    @articles = Article.where( :published => 1).order('published_on DESC, created_on DESC').limit(5)
  end
  
  # Shows a paginated list of all published articles on the site, optionally filtered either by date (year/month) or
  # Category
  #
  # === Expected parameters
  #
  # [:year]   the year by which to filter articles  (optional)
  # [:month]  the month by which to filter articles   (optional)
  # [:slug]   the slug of the Category by which to filter articles (optional)
  #
  # *Note*: @:year@/@:month@ and @:slug@ are mutually exclusive. If both are specified, articles are filtered by date.
  def list
    
    # basic conditions
    conditions  = [ 'published = ?', true ]
    join        = ''
    
    # if we have a year
    if params.key?('year')
      # if we also have a month…
      if (params.key?('month') and params[:month].to_i.between?(1,12))
        start  = Date.new(params[:year].to_i, params[:month].to_i, 1)
        finish = start + 1.month
        
        @sub_title = "/ "+start.strftime('%B %Y')
      else
        start  = Date.new(params[:year].to_i, 1, 1)
        finish = start + 1.year
        
        @sub_title = "/ #{params[:year]}"
      end
      
      # add conditions
      conditions[0] << ' AND published_on >= ? AND published_on < ?'
      conditions << start
      conditions << finish
    
    # otherwise, if we're filtering by category
    elsif params.key?('slug')
      
      # gack category
      cat = Category.find_by_url_slug(params[:slug])
      if cat.nil?
        not_found and return
      end
      
      join = ' JOIN articles_categories AS ac ON (articles.id = ac.article_id)'
      conditions[0] << ' AND ac.category_id = ?'
      conditions << cat.id
      
      @sub_title = "/ #{cat.title}"
    end
    
    @articles = Article.paginate(
      :conditions => conditions,
      :order  => 'published_on DESC, created_on DESC',
      :page   => params[:page],
      :joins  => join
    )
    
    @page_title = "Archive"
    @archive = Article.load_archive
  end
  
  # Shows the (published) article identified by the provided URL slug
  #
  # === Expected parameters
  #
  # [:slug] the @url_slug@ of the article to show.
  def show
    
    @article = Article.find_by_full_url_and_published( params[:slug], true )
        
    if @article.nil?
      not_found and return      
    end
    
    # set meta content
    @page_title = @article.title
    self.meta_description = @article.extract_rendered
    self.og_image = @article.masthead.file.url(:original) unless @article.masthead.nil?
  end
  
end