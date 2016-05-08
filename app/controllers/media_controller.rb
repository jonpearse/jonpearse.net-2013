# This handles serving up responsive media for the site.
#
#
class MediaController < ApplicationController

  # Allows a browser to register its current resolution/breakpoint with the session. This is then used by #view as
  # a default when serving images.
  #
  # === Expected parameters
  #
  # [:size]   the current CSS breakpoint being used.
  def ping

    # 1. update the cookie
    cookies[:resolution] = { value: params[:size], expires: 1.month.from_now }

    # 2. send a nocache header
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1970 00:00:00 GMT"

    # 3. and empty content
    head :no_content

  end

  # Serves up an appropriately-sized version of the requested Media item.
  #
  # By default, this will attempt to read the last breakpoint sent to #ping. If there is no stored breakpoint, it will
  # default to mobile view (or desktop in older IEs). Alternatively, you can specify a specific resolution to return
  # as a GET parameter.
  #
  # === Expected parameters
  #
  # [:id]           the ID of the Media item to return
  # [:resolution]   the resolution to return, if you wish to override the last stored resolution (optional)
  def view

    # 1. grab media
    begin
      @media = Media.find params[:id]
    rescue
      not_found and return
    end

    # 2. work out which size to use
    if params.key?('size')

      # accessing from parameter
      size = params[:size]

    elsif cookies[:resolution].present?

      # using size in cookie from previous ping
      size = cookies[:resolution]

    else

      # fallback to mobile: we'll let JS flange with it a little ;)
      # ... unless we're in IE8, in which case... blah!
      size = request.env['HTTP_USER_AGENT'] =~ /MSIE (6|7|8)/ ? 'desktop' : 'mobile'

    end

    puts "Pinging #{size}"

    # 3. check we have the correct path
    path = @media.file.path(size.to_sym)
    logger.debug path
    unless File.exist?(path)
      not_found and return
    end

    # 4. return
    send_data(File.open(path, 'rb').read, :type => @media.file.content_type, :disposition => 'inline')

  end

end
