# Rather messy superclass that abstracts all basic CRUD-type behaviour into one place. This means model-specific
# controllers can be <em>way</em> simpler.
#
# On the flip-side, this class is full of kludge and unpleasantness and is probably a good example of how not to do
# things. It was a good learning experience, though…

class Admin::ContentController < Admin::AdminController
  helper_method :sort_column, :sort_direction, :searchable?, :createable?, :choose_view
  attr_accessor :content_object, :default_sort_column, :default_sort_direction, :allow_create, :choose_view

  # search hooks-only respond to JSON, and don't worry about checksumming-it's only a GET
  respond_to :json, :only => :search
  protect_from_forgery :except => :search

  def initialize
    super
    self.default_sort_column    = 'created_on'
    self.default_sort_direction = 'd'
    self.allow_create           = false
    self.default_sort_column    = 'id'
    self.choose_view            = 'table'
  end

  # Displays a list of content, optionally sorted by criteria that will vary from model to model
  #
  # === Expected parameters
  #
  # [sb]    the column by which to sort the list
  # [sd]    the direction in which to sort the list (either 'u' or 'd', defaults to 'd')
  # [page]  the page of content to show
  # [q]     an optional search keyword
  #
  def index
    order = sort_column + " " + (sort_direction == 'u' ? 'ASC' : 'DESC')    
    @content = params.key?('q') ?
                content_object.where(search_clause).paginate( :page => params[:page] ).order( order ) :
                content_object.paginate( :page => params[:page] ).order( order )
                
    respond_to do |format|
      format.html
      format.json { render :json => @content }
      format.js
    end
  end

  # Allows a user to ‘choose’ an item of content. The functionality is broadly similar to #index, but may have additional
  # filtering logic so we can restrict what the user sees.
  #
  # There are probably better ways of doing this…
  #
  # === Expected parameters
  #
  # [sb]    the column by which to sort the list
  # [sd]    the direction in which to sort the list (either 'u' or 'd', defaults to 'd')
  # [page]  the page of content to show
  # [q]     an optional search keyword
  #
  # Note: different controllers may specify additional parameters suited to their requirements. See the #choose_clause
  # method for more information  
  def choose

    if createable? and params.key?('new')
      new
    else
      conditions = (searchable? and params.key?('q')) ? search_clause : ['1 = 1']
    
      # overlay local params
      choose_clause conditions
        
      # now grab order parm   
      order = sort_column + " " + (sort_direction == 'u' ? 'ASC' : 'DESC')    
    
      # query
      @content = content_object.where(conditions).order(order).paginate(
        :page       => params[:page]
      )
    end
    
    if request.xhr?
      render :layout => nil and return
    end
  end
  
  # Extracts and displays the content with the provided ID
  #
  # === Expected parameters
  #
  # [id]  the ID of the Article to publish
  def show
    @content = content_object.find(params[:id])
  end

  # Extracts and displays the content with the given ID in an ‘embeddable’ manner, otherwise identical to #show
  #
  # === Expected parameters
  #
  # [id]  the ID of the Article to publish
  def embed
    show
    
    if request.xhr?
      render :layout => nil and return
    end
  end

  # Previews the content with the given ID.
  #
  # === Expected parameters
  #
  # [id]    the ID of the Article to publish
  # [live]  attempt to show the latest version of the content, which may not be what is persisted in the database
  #         (optional)
  def preview
    
    @content = acquire_content_object
    
    render :layout => 'preview'
    
  end

  # Create a new item of content.
  def new
    
    @content = acquire_content_object

  end

  # Callback from #new, attempt to persist the new content. If this fails, the template for #new is rendered with
  # appropriate messaging.
  #
  # === Expected parameters
  #
  # [content]      a hash containing the content to be persisted
  def create
    @content = content_object.new object_params
  
    if params.key?('preview')
      prepare_preview and return
    end
  
    if @content.save
      clean_previews
      
      respond_to do |format|
        format.html do 
          flash[:notice] = t(:created)
          redirect_to after_create(@content)
        end
        format.js
      end
    else
      render :action => :new
    end
  end

  # Edit the content specified by the given ID. This hooks into preview functionality, and will attempt to load the
  # latest version of the content, which may differ from what is persisted in the database.
  #
  # === Expected parameters
  #
  # [id]  the ID of the Article to publish
  def edit

    @content = acquire_content_object

  end

  # Callback from #update: attempt to persist changes to the specified content. If this fails, the template for #update
  # is rendered with appropriate messaging.
  #
  # === Expected parameters
  #
  # [id]        the ID of the Article to publish
  # [content]   a hash containing the content to be persisted
  def update
    
    # Grab our content and attempt to update it
    @content = content_object.find(params[:id])
    @content.assign_attributes(object_params)
  
    if params.key?('preview')
      prepare_preview and return
    end
  
    if @content.save
      flash[:notice] = t(:edited)
      
      clean_previews
    
      redirect_to after_update(@content)
    else
      render :action => :edit
    end
  end

  # Destroys (unpersists) the content with the given ID. This has no checking and assumes that you meant to do it…
  #
  # === Expected parameters
  #
  # [id]  the ID of the Article to publish
  def destroy
    @content = content_object.find(params[:id])
    @content.destroy
    flash[:notice] = t(:deleted)
    
    clean_previews
    
    redirect_to after_destroy(@content) and return
  end

  # Provides an AJAX-esque search endpoint.
  #
  # This is now an alias for #index
  alias_method :search, :index

  protected 
    # Returns the path to which the user should be redirected after content has been created. This is provided so
    # subclasses can override default behaviour as required.
    #
    # === Parameters
    #
    # [c] the recently-created content
    def after_create( c )
      if params.key?('back_to')
        params[:back_to]
      else
        get_index_path
      end
    end
  
    # Returns the path to which the user should be redirected after content has been updated. This is provided so
    # subclasses can override default behaviour as required.
    #
    # === Parameters
    #
    # [c] the recently-updated content
    def after_update( c )
      if params.key?('back_to')
        params[:back_to]
      else
        get_index_path
      end
    end
  
    # Returns the path to which the user should be redirected after content has been destroyed. This is provided so
    # subclasses can override default behaviour as required.
    #
    # === Parameters
    #
    # [c] the recently-destroyed content
    def after_destroy( c )
      if params.key?('back_to')
        params[:back_to]
      else
        get_index_path
      end
    end

    # Returns some kind of content/string that can be used as a @:condition@ for ActiveRecord#all that allows searching
    # on the appropriate content for this controller.
    def search_clause
      nil
    end
      
    # Returns whether this content is searchable. By default, this will return false if #search_clause is nil.
    def searchable?
      !search_clause.nil?
    end
  
    # Returns whether this controller should allow the linked content to be controllable.
    def createable?
      allow_create
    end
    
    def choose_clause( conditions )
    end
    
    def object_params( data = nil )
      
      # basic names
      accepted_params = content_object.column_names.map { |field| field.to_sym }
          
      # additional params
      accepted_params.concat additional_params
      
      # sink
      data ||= params.require(:content)
      
      data.permit(accepted_params)
    end
    
    def additional_params
      []
    end

  private
    # Returns the sort column for the current #index or #search query
    def sort_column
      (params.key?('sb') and content_object.column_names.include?(params[:sb])) ? params[:sb] : default_sort_column
    end

    # Returns the sort direction for the current #index or #search query  
    def sort_direction
      (params.key?('sd') and %w[u d].include?(params[:sd])) ? params[:sd] : default_sort_direction
    end
  
    # Returns this index path for the linked object. This is a convenience method due to the way Rails handles resources
    # with uncountable names.
    #
    # Note: it’d be really nice if Rails provided a “get me the name of the x path for resource y” method…
    def get_index_path
      co  = content_object.to_s
      add = co.uncountable? ? '_index' : ''
      
      send("admin_#{co.underscore.pluralize}#{add}_path")
    end
    
    # Utility function that returns the content with the ID specified in @params[:id]@. Additionally, if @params[:live]@
    # is specified, this will attempt to hook into Preview functionality and return the most recent version of the
    # content it can find.
    def acquire_content_object
      
      # load object
      if params.key?('id')
        content = content_object.find params[:id]    
      else
        content = content_object.new
      end
      
      # if we're in live mode, update it with the current data
      if params.key?('live')

        # see if we have a preview
        preview = Preview.acquire(content_object.to_s, current_user)

        # if so, recall preview data into the object
        if preview.persisted?
          content.assign_attributes object_params(preview.model_data)
          content.run_callbacks(:save) { false }
        end
        
      end
      
      content      
    end
    
    # Saves a Preview version of the current content.
    def prepare_preview
      
      # 1. create preview object and stick it in the session
      preview = Preview.acquire(content_object.to_s, current_user)
      
      # 2. save some data into it
      preview.store(params[:content])
      
      # 3. tickle the content (for the sake of renderable)
      @content.run_callbacks(:save) { false }
            
      # 4. render to screen
      render :action => :preview, :layout => 'preview'
    end
    
    # Clears all previews for the current user/bound object.
    def clean_previews
      
      Preview.clean(content_object.to_s, current_user)
      
    end
end