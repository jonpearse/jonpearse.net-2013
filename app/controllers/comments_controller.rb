# Provides majority of front-end functionality surrounding {comments}[rdoc-ref:Comment] on the site.
class CommentsController < ApplicationController
  include UrlHelper

  before_filter :acquire_article,     :except => [ :edit, :update, :screen, :destroy, :show ]
  before_filter :authenticate_user!,  :only   => [ :edit, :update, :screen, :destroy ]

  # Shows all the comments on the given article.
  #
  # === Expected parameters
  #
  # [:slug] the @url_slug@ of the article to show comments for
  def index

    @comments = params.has_key?('latest') ? @article.comments.latest : @article.comments.viewable

  end

  # Loads the given article singly (used mostly as a callback from save, below)
  #
  # == Expected parameters
  #
  # [:id]     the @id@ of the comment to show
  def show

    @comment = Comment.find params[:id]
    @article = @comment.article

  end


  # Adds a comment to the the given article
  #
  # === Expected parameters
  #
  # [:slug]     the @url_slug@ of the article we're commenting on
  # [:reply_to] the ID of a comment to reply to (optional)
  def new

    @comment  = Comment.new
    @reply_to = nil

    # if we're replying to something
    if params.key?('reply_to')
      begin
        # grab comment
        @reply_to = Comment.find(params[:reply_to])
        @comment.reply_to_id = @reply_to.id

        # add comment text to the current comment
        @comment.comment = '> '+@reply_to.comment.gsub(/^>(.*?)\n/m, '').strip.gsub(/\n\n+/, "\n\n").gsub(/\n/, "\n> ")
      rescue
      end
    end

    unless cookies[:comment_details].nil?
      begin
        data = JSON.parse(cookies[:comment_details])
        @comment.name     = data["name"] unless data["name"].nil?
        @comment.email    = data["email"] unless data["email"].nil?
        @comment.website  = data["website"] unless data["website"].nil?
        @comment.save_deets = true
      rescue
      end
    end

  end

  # Attempts to save a comment posted about the given article
  #
  # === Expected parameters
  #
  # [:slug]     the @url_slug@ of the article we're commenting on
  def create

    @comment = Comment.new params.require(:comment).permit(:name, :email, :website, :reply_to_id, :is_human, :comment, :save_deets)
    @comment.article_id = @article.id
    @comment.ip = request.remote_ip

    if @comment.save

      # 1. set cookie, if required
      if @comment.save_deets == "1"
        value = { :name => @comment.name, :email => @comment.email, :website => @comment.website }.to_json
        cookies[:comment_details] = { value: value, :expires => 1.year.from_now }
      else
        cookies.delete :comment_details
      end

      # 2. save
      respond_to do |format|
        format.html do
          flash[:notice] = "Your comment has been added"
          redirect_to article_path(@article)+"#comment-#{@comment.id}"
        end
        format.json do
          render :show
        end
      end

    else

      unless @comment.reply_to_id.nil?
        @reply_to = @comment.parent
      end

      render :new, :locals => { :status => "failed" }
    end
  end

  # Attempts to edit a comment posted about the given article: requires admin access
  #
  # == Expected parameters
  #
  # [:id]     the @id@ of the comment to edit
  def edit

    respond_to do |format|
      format.html do
        forbidden and return
      end
      format.json do
        @comment = Comment.find params[:id]
      end
    end

  end

  # Callback from #edit, above: attempts to save an edited article: requires admin access
  #
  # == Expected parameters
  #
  # [:id]     the @id@ of the comment to edit
  def update

    @comment = Comment.find params[:id]

    if @comment.update_attributes params.require(:comment).permit(:name, :email, :website, :comment)
      @article = @comment.article;
      render :show
    else
      render :edit
    end

  end

  # Nukes a comment
  #
  # == Expected parameters
  #
  # [:id]   the @id@ of the comment to delete
  def destroy

    respond_to do |format|
      format.html do
        forbidden and return
      end
      format.json do
        Comment.find(params[:id]).destroy
      end
    end

  end

  # Screens a comment
  #
  # == Expected parameters
  #
  # [:id]   the @id@ of the comment to delete
  def screen

    respond_to do |format|
      format.html do
        forbidden and return
      end
      format.json do
        @comment = Comment.find params[:id]

        @comment.update_attribute(:screened, params[:screen])
      end
    end

  end

  private
    def acquire_article

      @article = Article.find_by_full_url_and_published(params[:slug], true)

      if @article.nil?
        not_found and return
      end

    end

end
