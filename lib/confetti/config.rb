module Confetti
  class Config
    include Helpers
    include PhoneGap
    self.extend TemplateHelper

    attr_accessor :package, :version_string, :version_code, :description,
                  :height, :width, :plist_icon_set, :url_scheme_set
    attr_reader :author, :viewmodes, :name, :license, :content,
                :icon_set, :feature_set, :preference_set, :xml_doc,
                :splash_set, :plist_icon_set, :access_set, :plugin_set,
                :url_scheme_set, :platform_set

    generate_and_write  :android_manifest, :android_strings, :ios_info, 
                        :ios_remote_plist, :windows_phone8_manifest

    # handle bad generate/write calls
    def method_missing(method_name, *args)
      bad_call = /^(generate)|(write)_(.*)$/
      matches = method_name.to_s.match(bad_call)

      if matches
        raise FiletypeError, "#{ matches[3] } not supported"
      else
        super method_name, *args
      end
    end

    def initialize( *args )
      @author           = Author.new
      @name             = Name.new
      @license          = License.new
      @content          = Content.new
      @icon_set         = TypedSet.new Image
      @plist_icon_set   = [] 
      @feature_set      = TypedSet.new Feature
      @platform_set     = TypedSet.new Platform
      @splash_set       = TypedSet.new Image
      @preference_set   = TypedSet.new Preference
      @access_set       = TypedSet.new Access
      @url_scheme_set   = TypedSet.new UrlScheme

      # defined in PhoneGap module
      @plugin_set       = TypedSet.new Plugin
      @viewmodes        = []

      return if args.empty?

      input = args[0]
      strict = args[1] || false

      if is_file?( input ) || File.extname( input ) == ".xml"
        populate_from_xml input, strict
      elsif input.kind_of?( String )
        populate_from_string input, strict
      end
    end

    def populate_from_xml( xml_file, strict = false )
      begin
        file = File.read(xml_file)
      rescue Errno::ENOENT
        raise FileError, "file #{ xml_file } doesn't exist"
      end
      
      populate file, strict 
    end

    def populate_from_string( xml_str, strict = false )
      populate xml_str, strict
    end

    def populate( config_doc, strict = false )
      
      # confirm valid encoding
      if config_doc && !config_doc.valid_encoding?
        raise XMLError, "malformed config.xml"
      end

      begin
        config_doc = Nokogiri::XML( config_doc ) { |config| 
          strict ? config.nonet.strict : config.nonet.recover
        }.root
      rescue Nokogiri::XML::SyntaxError, TypeError, RuntimeError
        raise XMLError, "malformed config.xml"
      end

      if config_doc.nil?
        raise XMLError, "no doc parsed"
      end

      @xml_doc = config_doc # save reference to doc

      @package = config_doc["id"]
      @version_string = config_doc["version"]
      @version_code = config_doc["versionCode"]

      icon_index = 0
      splash_index = 0

      config_doc.elements.each do |ele|
        attr = {}
        ele.attributes.each { |k, v| attr[k] = v.to_s }

        ele_namespace = ele.namespace ? ele.namespace.href : "http://www.w3.org/ns/widgets"

        case ele_namespace

        # W3C widget elements
        when "http://www.w3.org/ns/widgets"
          case ele.name
          when "name"
            @name = Name.new(ele.text.nil? ? "" : ele.text.strip,
                              attr["shortname"])

          when "author"
            @author = Author.new(ele.text.nil? ? "" : ele.text.strip,
                                  attr["href"], attr["email"])

          when "description"
            @description = ele.text.nil? ? "" : ele.text.strip

          when "icon"
            icon_index += 1
            @icon_set << Image.new(attr["src"], attr["height"], attr["width"],
                                    attr, icon_index)
            # used for the info.plist file
            @plist_icon_set << attr["src"]

          when "feature"
            feature = Feature.new(attr["name"], attr["required"])

            ele.search("param").each do |param|
              feature.param_set << Param.new(param["name"], param["value"])
            end

            @feature_set  << feature

          when "preference"
            @preference_set << Preference.new(attr["name"], attr["value"],
                                              attr["readonly"])

          when "license"
            @license = License.new(ele.text.nil? ? "" : ele.text.strip,
                                   attr["href"])

          when "access"
            sub = boolean_value(attr["subdomains"], true)
            browserOnly = boolean_value(attr["browserOnly"])
            launchExternal = attr["launch-external"] == "yes"
            @access_set << Access.new(attr["origin"], sub, browserOnly, launchExternal)

          when "content"
            @content = Content.new(attr["src"], attr["type"], attr["encoding"])

          end

        # PhoneGap extensions (gap:)
        when "http://phonegap.com/ns/1.0"
          case ele.name
          when "platform"
            @platform_set << Platform.new(attr["name"])
          when "splash"
            next if attr["src"].nil? or attr["src"].empty?
            splash_index += 1
            @splash_set << Image.new(attr["src"], attr["height"], attr["width"],
                                      attr, splash_index)
          when "url-scheme"
            schms = ele.search('scheme').map { |a| a.text }
            schms.reject! { |a| a.nil? || a.empty? }
            next if schms.empty?
            @url_scheme_set << UrlScheme.new(schms, attr["name"], attr["role"])
            
          when "plugin"
            next if attr["name"].nil? or attr["name"].empty?
            plugin = Plugin.new(
              attr["name"], 
              attr["version"], 
              attr["platform"] || attr["platforms"], 
              attr["source"]
            )
            ele.search("param").each do |param|
              plugin.param_set << Param.new(param["name"], param["value"])
            end
            @plugin_set << plugin
          end
        end
      end
    end

    def icon
      @icon_set.first
    end

    def biggest_icon
      @icon_set.max { |a,b| a.width.to_i <=> b.width.to_i }
    end

    def splash
      @splash_set.first
    end

    # simple helper for grabbing chosen orientation, or the default
    # returns one of :portrait, :landscape, or :default
    def orientation
      values = [:portrait, :landscape, :default]
      choice = preference :orientation

      unless choice and values.include?(choice)
        :default
      else
        choice
      end
    end

    # helper to retrieve a preference's value
    # returns nil if the preference doesn't exist
    def preference name
      pref = preference_obj(name)

      if pref && pref.value && !pref.value.empty?
        pref.value.to_sym
      end
    end

    # mostly an internal method to help with weird cases
    # in particular #phonegap_version
    def preference_obj name
      name = name.to_s
      @preference_set.detect { |pref| pref.name == name }
    end

    def feature name
      @feature_set.detect { |feature| feature.name == name }
    end

    def full_access?
      @access_set.detect { |a| a.origin == '*' }
    end

    def find_best_fit_img images, opts, required=true

      opts['width']     ||= :no_match
      opts['height']    ||= :no_match
      opts['role']      ||= :no_match
      opts['density']   ||= :no_match
      opts['state']     ||= :no_match
      opts['platform']  ||= :no_match

      no_attributes = {
        'width'     => nil,
        'height'    => nil,
        'role'      => nil,
        'density'   => nil,
        'state'     => nil,
        'platform'  => nil,
        'qualifier' => nil
      }

      filters = [
        {'platform' => opts['platform'], 'height' => opts['height'], 'width' => opts['width']},
        {'platform'  => nil, 'height' => opts['height'], 'width' => opts['width']},
        {'platform' => opts['platform'], 'density' => opts['density']},
        {'platform'  => nil, 'density' => opts['density']},
        {'platform' => opts['platform'], 'state' => opts['state']},
        {'platform'  => nil, 'state' => opts['state']},
        {'platform' => opts['platform'], 'role' => opts['role']},
        {'platform'  => nil, 'role' => opts['role']}
      ]

      if required # match platform default, global default, first file without a platform
        filters << no_attributes.merge({'platform' => opts['platform']})
        filters << no_attributes
        filters << {'platform'  => nil}
      end

      matches = nil

      filters.each do |filter|
        matches = filter_images(images, filter)

        if matches.length > 0
          break
        end
      end

      if !matches.empty?
        return matches.sort {|a,b| a.index.to_i <=> b.index.to_i }.first
      end
      nil
    end

    def default_icon
      @icon_set.each do |icon|
        return icon if icon.src.match /^icon(\.[a-zA-Z0-9]+)+$/i
      end
      nil
    end

    def default_splash
      @splash_set.each do |splash|
        return splash if splash.src.match /^splash(\.[a-zA-Z0-9]+)$/i
      end
      nil
    end

    def filter_images images, filter
      imgs = images.clone
      filter.each_pair do |name, value|
        imgs = imgs.select { |img|
          value_to_match = img.send(name)

          if value_to_match.nil? # missing attr only matches nil
            value.nil?
          else 
            value_to_match.split(',').any? { |a| 
              value == '*' || a.strip == '*' || a.strip == value
            }
          end
        }
      end

      imgs
    end

    # convert string (attribute) to boolean
    def boolean_value value, default=false
      if default
        value != "false"
      else
        value == "true"
      end
    end
  end
end
