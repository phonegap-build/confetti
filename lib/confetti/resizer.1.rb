module Confetti
  module Resizer

    @platforms = [ :android, :ios ]

    @icon = {
      :ios => [
        { :width => 1024, :height => 1024 },
        { :width => 180,  :height => 180  },
        { :width => 167,  :height => 167  },
        { :width => 152,  :height => 152  },
        { :width => 120,  :height => 120  },
        { :width => 87,   :height => 87   },
        { :width => 80,   :height => 80   },
        { :width => 60,   :height => 60   },
        { :width => 58,   :height => 58   },
        { :width => 40,   :height => 40   }
      ],
      :android => [
        { :width => 192, :height => 192, :density => 'xxxhdpi' },
        { :width => 144, :height => 144, :density => 'xxhdpi'  },
        { :width => 96,  :height => 96,  :density => 'xhdpi'   },
        { :width => 72,  :height => 72,  :density => 'hdpi'    },
        { :width => 48,  :height => 48,  :density => 'mdpi'    }
      ]
    }
    
    @splash = {
      :ios => {
        :portrait => [
          { :width => 2048, :height => 2732 },
          { :width => 1668, :height => 2224 },
          { :width => 1536, :height => 2048 },
          { :width => 1125, :height => 2436 },
          { :width => 1242, :height => 2208 },
          { :width => 750,  :height => 1334 },
          { :width => 640,  :height => 1136 }
        ],
        :landscape => [
          { :height => 2048, :width => 2732 },
          { :height => 1668, :width => 2224 },
          { :height => 1536, :width => 2048 },
          { :height => 1125, :width => 2436 },
          { :height => 1242, :width => 2208 },
          { :height => 750,  :width => 1334 },
          { :height => 640,  :width => 1136 }
        ]
      },
      :android => {
        :portrait => [
          { :width => 1280, :height => 1920, :density => 'xxxhdpi' },
          { :width => 960,  :height => 1600, :density => 'xxhdpi'  },
          { :width => 720,  :height => 1280, :density => 'xhdpi'   },
          { :width => 480,  :height => 800,  :density => 'hdpi'    },
          { :width => 320,  :height => 480,  :density => 'mdpi'    }
        ],
        :landscape => [
          { :height => 1280, :width => 1920, :density => 'land-xxxhdpi' },
          { :height => 960,  :width => 1600, :density => 'land-xxhdpi'  },
          { :height => 720,  :width => 1280, :density => 'land-xhdpi'   },
          { :height => 480,  :width => 800,  :density => 'land-hdpi'    },
          { :height => 320,  :width => 480,  :density => 'land-mdpi'    }
        ]
      }
    }

    @valid_orientations = [ 'both', 'landscape', 'portrait' ]
    @valid_modes = [ 'shrink', 'stretch', 'crop' ]
    @valid_gravities = [ 'center', 'north', 'south', 'east', 'west', 'northwest', 'northeast', 'southeast', 'southwest' ]
    @gravity_abbreviations = { 'c': 'center', 'n': 'north', 's': 'south', 'e': 'east', 'w': 'west', 'nw': 'northwest',
      'ne': 'northeast', 'se': 'southeast', 'sw': 'southwest' }
  
    def resize src, target, width, height = width, gravity = 'center', shrink = true, pad_colour = nil
  
      gravity = (gravity || 'centre').downcase.strip
      gravity = @gravity_abbreviations[gravity.to_sym] || gravity
      gravity = 'center' if !@valid_gravities.include?(gravity)
  
      if pad_colour && pad_colour !~ /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/
        pad_colour = nil
      end
  
      p "#{src} -> #{target} #{width}x#{height} gravity=#{gravity} shrink=#{shrink} pad_colour=#{pad_colour}"

      is_svg = src =~ /.svg$/

      if is_svg

        command = ['rsvg-convert', '-a', '-o', target]
        command.concat ['-b', "'" + (pad_colour || 'white') + "'"]
        command.concat [ '-w', width, '-h', height ] if shrink
        command << src
        p command

        `#{command.join(' ')}`

        src = target
        FileUtils.cp src, src + '2.png'

      end
      
      MiniMagick::Tool::Convert.new do |convert|
        convert << src

        if pad_colour
  
          convert.geometry("#{width}x#{height}>")
          convert.gravity(gravity)
          convert.background(pad_colour)
          convert.extent("#{width}x#{height}")

        else

          convert.geometry("#{width}x#{height}^") if !!shrink
          convert.gravity(gravity)
          convert.crop("#{width}x#{height}+0+0")
  
        end

        convert << target

      end

      ImageOptimizer.new(target, level: 0).optimize if !is_svg
    
    end
    module_function :resize

    def go!
      xml_doc = nil

      config = Confetti::Config.new('resize/config.xml', true)
      platforms = config.platform_set.map{ |platform| platform.name.to_sym }
      platforms = platforms & @platforms
      platforms = @platforms if platforms.empty?

      p "platforms in config.xml - #{platforms}"

      begin
        xml_doc = Nokogiri::XML( File.read('resize/config.xml') ) { |config|
          config.nonet.strict
          config.default_xml.noblanks
        }
      rescue Nokogiri::XML::SyntaxError, TypeError, RuntimeError
        raise XMLError, "malformed config.xml"
      end

      to_resize = xml_doc.xpath("/*/xmlns:splash[@resize='true']|/*/xmlns:platform/xmlns:splash[@resize='true']|/*/xmlns:icon[@resize='true']|/*/xmlns:platform/xmlns:icon[@resize='true']")

      done = []

      new_folder = 'resize/_images'
      FileUtils.rm_rf(new_folder)
      FileUtils.mkdir(new_folder)
      FileUtils.touch(new_folder + '/.pgbomit')

      to_resize.each { |element|

        new_element = Nokogiri::XML::NodeSet.new(xml_doc)

        use_platform_tag = true
        if element.parent.name == 'platform'
          platform = element.parent["name"].to_sym
          use_platform_tag = false
        elsif element['platform']
          platform = element['platform'].to_sym
        else
          platform = platforms
        end

        platform = Array(platform) & platforms

        next if platform.length == 0

        platform.each { |platform|

          nodes = Nokogiri::XML::NodeSet.new(xml_doc)

          p "#{platform} - #{use_platform_tag} - #{element.name} - #{element['orientation']}"

          image_set = @icon[platform]
          if element.name == 'splash'
            image_set = @splash[platform]
            if element['orientation'] == 'both'
              image_set = image_set[:portrait] | image_set[:landscape]
            elsif element['orientation'] == 'landscape'
              image_set = image_set[:landscape]
            else
              image_set = image_set[:portrait]
            end
          end

          # 37.8  23.013  - no stuff
          # 37.8  49.686s - only end opt
          # 37.8  27.5    - convert then no stuff

          maxh = 0
          maxw = 0
          image_set.each { |img|
            maxh = img[:height] if maxh < img[:height]
            maxw = img[:width] if maxw < img[:width]
          }

          #`convert #{element['src']} -resize #{maxh}x #{element['src']}.png`
          #ImageOptimizer.new(element['src'] + '.png').optimize
          
          #poopy = element['src'] + '.png'
          #poopy = element['src']

          image_set.each { |img|
            img_tag = xml_doc.create_element(element.name)
            img.each { |k, v| img_tag[k] = v }
            target_src = new_folder+"/#{element.name}-#{platform}-#{img[:width]}x#{img[:height]}.png"
            next if done.include? target_src
            done << target_src

            resize(element['src'], target_src,img[:width], img[:height], element['gravity'], element['shrink'] != 'false', element['pad_colour'] || element['pad_color'])
            img_tag[:src] = target_src
            nodes << img_tag
          }

          if use_platform_tag
            platform_tag = xml_doc.create_element('platform')
            platform_tag[:name] = platform
            platform_tag.children = nodes
            new_element << platform_tag if platform_tag.children.length > 0
          else
            new_element = nodes
          end
        }

        element.add_next_sibling new_element
        element.remove
        
      }

      File.write('resize/new_config.xml', xml_doc.to_xml(:indent => 2))
    end
    module_function :go!



  end
end

# "icons-" + Time.now.strftime('%Y%m%d%H%M%S%L')