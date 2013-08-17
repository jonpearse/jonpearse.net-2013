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
    
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = ((column == sort_column) and (sort_direction == "d")) ? 'u' : 'd'
    page      = params.key?('page') ? params[:page] : nil
    
    link_to title, { :sb => column, :sd => direction, :page => page }, :class => css_class
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

end