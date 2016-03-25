# This is a very simple controller that provides functionality surrounding {pages}[rdoc-ref:Page]
class PageController < ApplicationController
  
  # Note: because this controller catches all unrouted requests, it will occasionally receive requests for non-existent
  #       JS files.
  #       By default, Rails’ verification-fu will automatically flag this as Bad And Wrong and throw a wobbly. Instead,
  #       let’s just suspend this and return a normal 404, because that’s what it actually is…
  skip_before_action :verify_authenticity_token

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
