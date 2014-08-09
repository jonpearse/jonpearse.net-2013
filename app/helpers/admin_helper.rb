# Provides various view functions that might be useful in the {Admin}[rdoc-ref:Admin] section of the site.
module AdminHelper
  
  # Creates a header for a table that allows interactive sorting.
  #
  # === Parameters
  #
  # [column]  the name of the column in the database to sort by
  # [title]   the human-readable title of this column (optional, inherits from @column@)
  #
  def sortable( column, title = nil )
    title ||= column.titleize
    
    css_class  = (column == sort_column) ? "current #{sort_direction}" : nil
    direction  = ((column == sort_column) and (sort_direction == "u")) ? 'd' : 'u'
    page       = params.key?('page') ? params[:page] : nil
    icon_class = (column == sort_column) ? ((sort_direction == 'u') ? 'rotate-90' : 'rotate-270') : 'rotate-90'
    
    if ((column == sort_column) && (sort_direction == 'd'))
      column = nil
      direction = nil
    end
    
    link_to_with_icon title, { :sb => column, :sd => direction, :page => page }, "play #{icon_class}", :class => "sortable #{css_class}", :icon_after => true, :data => { :remote => true }
  end
  
  # A quick and dirty function that produces localised content based on either a class definition or instance of an
  # ActiveRecord object.
  #
  # The only reason this exists is so I can abstract everything into the {ContentController}[rdoc-ref:Admin::ContentController]…
  def admin_t(object, action, subs = {})
        
    klass = object.is_a?(Class) ? object.to_s.underscore : object.class.name.underscore
    model = t("admin.model.#{klass}", :default => klass)
    
    subs[:model]    = model
    subs[:model_p]  = model.pluralize
    subs[:id]       = object.is_a?(Class) ? nil : object.id
    
    # return
    t "admin.prompt.#{action}", subs

  end
  
  # Outputs a selector control for the ‘choose’ action
  def select_control_for( content )
    
    if params.key?(:multiple)
      
      tag 'input', { :type => 'checkbox', :name => 'content_id', :value => content.id }, true
      
    else
      
      tag 'input', { :type => 'radio', :name => 'content_id', :value => content.id }, true
      
    end
    
  end
  
end