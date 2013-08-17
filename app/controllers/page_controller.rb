# This is a very simple controller that provides functionality surrounding {pages}[rdoc-ref:Page]
class PageController < ApplicationController
  
  # Shows the Page with the given URL slug. If the specified Page cannot be found, the user is shown a 404 page.
  #
  # === Expected parameters
  #
  # [:slug]   the URL slug of the Page to show
  def show
    
    @page = Page.find_by_url_slug( params[:slug] )

    if @page.nil?
      not_found and return
    end
    
    @page_title = @page.title
    
  end

end