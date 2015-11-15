# Provides view functions used all over the site.
module ApplicationHelper

  # Wraps ActionView::Helpers::UrlHelper#link_to to produce a link with an additional ‘current’ style if it links to
  # the page currently being viewed. This is useful for navigation sections
  #
  # === Parameters
  #
  # [text]    the text to link
  # [path]    the path to link to
  # [options] an array of additional options—see ActionView::Helpers::UrlHelper#link_to for more information.
  def link_to_with_current( text, path, options = {} )
    # default options
    options[:class] ||= ''
    options[:addClass] ||= 'current'

    # if we're on the current page, add a 'current' style
    if current_page?(path)
      options[:class] << " #{options[:addClass]}"
    end

    # remove additional class
    options.delete(:addClass)

    # pass off
    link_to text, path, options
  end

  # Formats a date into the form "Mar 5th, 2013"
  #
  # === Parameters
  #
  # [date]  the DateTime object to format
  def form_date( date, include_time = false )
    ret = include_time ? date.strftime('%H.%M, ') : ''
    ret + date.strftime("%b #{date.day.ordinalize}, %Y")
  end

  # Goes through text and replaces any dynamic references to Media items with appropriate markup.
  #
  # === Parameters
  #
  # [markup]  the markup to parse
  def process_media( markup )

    processed = false

    # render images
    markup.gsub!(/\$(?:\&(g|l)t;(!)?:)?media\.(\d+)(?:#(.*?))?\$/) do |m|
      processed = true

      begin
        # load media
        media = Media.find($3)

        # locals
        align   = $1.nil? ? 'center' : ($1 == 'l' ? 'left' : 'right')
        caption = $4
        pull    = !$2.nil?

        # return code
        render( :partial => "media/#{media.media_type}", :locals => { :media => media, :align => align, :caption => caption, :pull => pull } )
      rescue
        # something went wrong, so return nothing
        ''
      end
    end

    # render galleries
    markup.gsub!(/\$gallery\.(\d+)(?:#(.*?))?\$/) do |m|
      processed = true

      #begin
        # load media
        gallery = Gallery.find($1)

        # locals
        title = $2

        # return code
        render( :partial => "galleries/embed", :locals => { :gallery => gallery, :title => title } )
      #rescue
        # something went wrong, so return nothing
        #''
      #end
    end

    # tidy markup…
    if processed
      markup.gsub!(/<p><aside/, '<aside')
      markup.gsub!(/<\/aside>\s?(<\/p>|<br>|<br \/>)/, '</aside>')
    end
    markup
  end

  # The exact opposite of #process_media—this goes through markup and removes dynamic references to Media items.
  #
  # === Parameters
  #
  # [markup]  the markup from which to remove Media references
  def remove_media( markup )
    markup.gsub(/\$(?:\&(g|l)t;(!)?:)?(media|gallery)\.(\d+)(?:#(.*?))?\$/, '')
  end

  # Returns a gravatar for the specified email address
  #
  # === Parameters
  #
  # [email] the email address to return the gravatar for
  def gravatar_for( email, size = nil )
    url = "http://www.gravatar.com/avatar/"+Digest::MD5.hexdigest(email)+"?d=blank"+(size.nil? ? '' : '&s='+size.to_s )

    '<img src="'+url+'" alt="">'
  end

  # Provides a link with a fontawesome icon prepended
  #
  # === Parameters
  #
  # [body]          the text that should be linked
  # [url]           the URL of the link
  # [icon]          the icon that should be appended/prepended
  # [html_options]  any options that should be passed to link_to
  def link_to_with_icon( body, url, icon, html_options = {})

    link_text = html_options.key?(:icon_after) ? "#{body} "+fa_icon(icon) : fa_icon(icon)+" #{body}"
    html_options.delete(:icon_after)

    link_to link_text.html_safe, url, html_options

  end

  # Helper function to wrap FontAwesome-ness =)
  #
  # === Parameters
  #
  # [icon]          the icon that should be displayed. Separate multiple icons with spaces
  # [html_options]  any options that should be passed to the tag() function
  def fa_icon( icon, html_options = {} )

    html_options[:class] ||= ""
    html_options[:class].prepend " " unless html_options[:class].empty?
    html_options[:'aria-hidden'] = "true"

    if controller_path.starts_with? 'admin/'
      html_options[:class] += " fa fa-#{icon.split(/\s+/).join(' fa-')}"
      tag('i', html_options, true)+'</i>'.html_safe
    else
      "<svg class=\"i--#{icon}#{html_options[:class]}\"><use xlink:href=\"#icon-#{icon}\"/></svg>".html_safe
    end
  end


  # Embeds an SVG into the page
  #
  # === Parameters
  #
  # [filename]  the name of the file to embed (must be in app/assets/images)
  # [additional_class] an optional additional class to add to the SVG when embedding
  def embed_svg(filename, additional_class = nil)

    svg = File.open(Rails.root.to_s + '/app/assets/images/' + filename) { |f| Nokogiri::XML f }

    unless additional_class.nil?
      svg.root['class'] = additional_class
    end

    svg.to_html.html_safe

  end

  def google_authenticator_qrcode(user,qualifier=nil)
    username = username_from_email(user.email)
    app =   Rack::Utils.escape "jjp-lite"+(Rails.env=='development' ? '/dev' : '')
    data = "otpauth://totp/#{app}#{qualifier}?secret=#{user.gauth_secret}"
    data = Rack::Utils.escape(data)
    url = "https://chart.googleapis.com/chart?chs=200x200&chld=M|0&cht=qr&chl=#{data}"
    return image_tag(url, :alt => 'Google Authenticator QRCode')
  end
end
