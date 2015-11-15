namespace :jjp do
  desc "Performs some maintenance tasks"
  task :clean_up do

    puts "Cleaning old previews"
    Rake::Task['jjp:content:clean_previews'].invoke

  end

  namespace :content do
    desc "Removes stale previews"
    task :clean_previews => :environment do

      Preview.clean_old

    end
  end

  namespace :icons do
    desc "Rebuilds SVG icon"
    task :rebuild => :environment do

      # build new XML doc
      doc      = Nokogiri::XML::Document.new

      # SVG element
      root_el  = doc.create_element 'svg'
      doc.root = root_el
      root_el.add_namespace nil, "http://www.w3.org/2000/svg"
      root_el.add_namespace 'xlink', 'http://www.w3.org/1999/xlink'
      root_el.set_attribute 'height', '0'
      root_el.set_attribute 'width',  '0'

      # defs element
      defs_el = doc.create_element 'defs'
      root_el << defs_el

      # iterate through icons
      Dir.glob('app/assets/icons/*.svg').each do |svg_file|

        puts "Appending #{svg_file}"

        # open document
        svg_doc = File.open(svg_file) { |f| Nokogiri::XML(f) }

        # create our new node
        symbol_el = doc.create_element 'symbol'
        defs_el << symbol_el
        symbol_el.set_attribute 'id', 'icon-'+File.basename(svg_file, '.*')
        symbol_el.set_attribute 'viewBox', svg_doc.root.get_attribute('viewBox')

        # find some paths
        svg_doc.search('path').each do |path|
          # construct new path
          path_el = doc.create_element 'path'
          symbol_el << path_el

          # copy d attr across
          path_el.set_attribute 'd', path.get_attribute('d')
        end
      end

      # save the file out
      File.write('app/assets/images/icons.svg', doc.to_xml)

    end
  end
end
