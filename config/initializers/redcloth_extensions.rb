module RedCloth::Formatters::HTML
  # override for link, so external links open in a new window
  def link( opts )
    target = opts[:href].start_with?('http://','https://') ? ' rel="external"' : ''

    "<a href=\"#{escape_attribute opts[:href]}\"#{pba(opts)}#{target}>#{opts[:name]}</a>"
  end

  # Produce HTML5 breaks
  def hr (opts)
    "<div class=\"hr\"><hr></div>\n"
  end

  # Produce HTML5 images
  def image(opts)
    opts.delete(:align)
    opts[:alt] = opts[:title]
    img = "<img src=\"#{escape_attribute opts[:src]}\"#{pba(opts)} alt=\"#{escape_attribute opts[:alt].to_s}\">"
    img = "<a href=\"#{escape_attribute opts[:href]}\">#{img}</a>" if opts[:href]
    img
  end

  # HTML5 linebreaks
  def br(opts)
    if hard_breaks == false
      "\n"
    else
      "<br>\n"
    end
  end

  #
  # -- CODERAY INTEGRATION.
  #
  # This is largely inspired by coderay’s own RedCloth integration module, but with a few modifications to improve it
  # and tidy it up.
  def unescape(html)  # :nodoc:
    replacements = {
      '&amp;' => '&',
      '&quot;' => '"',
      '&gt;' => '>',
      '&lt;' => '<',
    }
    html.gsub(/&(?:amp|quot|[gl]t);/) { |entity| replacements[entity] }
  end
  undef code, bc_open, bc_close, escape_pre

  def bc_open(opts)  # :nodoc:
    opts[:block] = true
    opts[:class] = "block u-box u-code"+(opts[:lang].nil? ? '' : " -l-#{opts[:lang]}")
    @in_bc = opts
    opts[:lang] ? '' : "<pre#{pba(opts)}>"
  end

  def bc_close(opts)  # :nodoc:
    opts = @in_bc
    @in_bc = nil
    opts[:lang] ? '' : "</pre>\n"
  end

  def escape_pre(text)  # :nodoc:
    if @in_bc ||= nil
      text
    else
      html_esc(text, :html_escape_preformatted)
    end
  end


  def code(opts)

    @in_bc ||= nil

    # if we're inline, grab the bracketed language off the front
    unless @in_bc
      opts[:text].gsub!(/^\[([A-z]+?)\]\s+/) { |m| opts[:lang] = $1; '' }
    end

    # if we have a language, start formatting
    if opts[:lang]
      require 'coderay'

      opts[:text] = CodeRay.scan(opts[:text], opts[:lang].to_sym).html(:wrap => nil)

      # split by lines
      if @in_bc
        opts[:text].gsub!(/^\.$/, '')
        opts[:text] = opts[:text].split("\n").map{ |l| "<span class=\"code-line\">#{l}</span>" }.join("\n")
      end

      # grep for any tags
      opts[:text].gsub!(/\<span class="tag"\>&lt;(\/)?([a-z1-6]+)/) { |match| "<span class=\"tag\">&lt;#{$1}</span><span class=\"tag-name\">#{$2}</span><span class=\"tag\">" }

    end

    # if we have a counter param
    if opts[:style]
      opts[:style].gsub!(/start:(\d+)/) { |m| "counter-reset: code-hilite #{($1.to_i - 1)}" }
    end

    # finally, output based on whether we're inline or not
    @in_bc ?
        "\n<code#{pba(opts)}>#{opts[:text]}</code>" :
        "<code>#{opts[:text]}</code>"
  end
end
