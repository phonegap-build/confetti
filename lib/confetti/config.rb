module Confetti
  class Config
    include Helpers
    include PhoneGap
    self.extend TemplateHelper

    attr_accessor :package, :version_string, :version_code, :description,
                  :height, :width, :plist_icon_set, :url_scheme_set, :default_min_sdk,
                  :android_versioncode, :ios_cfbundleversion, :windows_package_version,
                  :windows_publisher_id, :windows_identity_name, :windows_package_name

    attr_reader :author, :viewmodes, :name, :license, :content,
                :icon_set, :feature_set, :preference_set, :xml_doc,
                :splash_set, :plist_icon_set, :access_set, :plugin_set,
                :url_scheme_set, :platform_set, :allow_navigation_set, :allow_intent_set

    generate_and_write  :android_manifest, :android_strings, :ios_info, 
                        :ios_remote_plist, :windows_phone8_manifest, :windows_manifest

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
      @allow_navigation_set = TypedSet.new AllowNavigation
      @allow_intent_set = TypedSet.new AllowIntent
      @url_scheme_set   = TypedSet.new UrlScheme
      @default_min_sdk  = 10

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

      config_doc = config_doc.gsub("gap:plugin", "gap_plugin") if config_doc

      begin
        @xml_doc = Nokogiri::XML( config_doc ) { |config|
          strict ? config.nonet.strict : config.nonet.recover
        }
      rescue Nokogiri::XML::SyntaxError, TypeError, RuntimeError
        raise XMLError, "malformed config.xml"
      end

      if config_doc.nil?
        raise XMLError, "no doc parsed"
      end

      @xml_doc.remove_namespaces!
      config_doc = @xml_doc.root

      @package                  = config_doc["id"]
      @version_string           = config_doc["version"]
      @version_code             = config_doc["versionCode"]

      @android_versioncode      = config_doc["android-versionCode"] 
      @ios_cfbundleversion      = config_doc["ios-CFBundleVersion"] 
      @windows_package_version  = config_doc["windows-packageVersion"]
      @windows_package_name     = config_doc["packageName"]

      icon_index = 0
      splash_index = 0

      config_doc.elements.each do |ele|
        attr = {}
        ele.attributes.each { |k, v| attr[k] = v.to_s }

        case ele.name
        when "name"
          @name = Name.new(ele.text.nil? ? "" : ele.text.strip,
                            attr["shortname"])

        when "author"
          @author = Author.new(ele.text.nil? ? "" : ele.text.strip,
                                attr["href"], attr["email"])

        when "description"
          @description = ele.text.nil? ? "" : ele.text.strip

        when "feature"
          feature = Feature.new(attr["name"], attr["required"])

          ele.search("param").each do |param|
            feature.param_set << Param.new(param["name"], param["value"])
          end

          @feature_set  << feature

        when "license"
          @license = License.new(ele.text.nil? ? "" : ele.text.strip,
                                 attr["href"])

        when "access"
          sub = boolean_value(attr["subdomains"], true)
          browserOnly = boolean_value(attr["browserOnly"])
          launchExternal = attr["launch-external"] == "yes"
          @access_set << Access.new(attr["origin"], sub, browserOnly, launchExternal)

        when "allow-navigation"
          @allow_navigation_set << AllowNavigation.new(attr["href"])

        when "allow-intent"
          @allow_intent_set << AllowIntent.new(attr["href"])

        when "content"
          @content = Content.new(attr["src"], attr["type"], attr["encoding"])

        when "platform"
          platform = attr["name"]
          platform.gsub! /^(wp8|windows)$/, "winphone" if !platform.nil?
          @platform_set << Platform.new(platform)

        when "url-scheme"
          schms = ele.search('scheme').map { |a| a.text }
          schms.reject! { |a| a.nil? || a.empty? }
          next if schms.empty?
          @url_scheme_set << UrlScheme.new(schms, attr["name"], attr["role"])
        end
      end

      # parse gap:plugin
      config_doc.xpath('//gap_plugin').each { |ele|
        attrs = get_attributes(ele)

        plugin = Plugin.new(attrs["name"], attrs["spec"] || attrs["version"] || attrs["src"], attrs["platform"], attrs["source"] || "pgb")
        ele.search("param").each do |param|
          plugin.param_set << Param.new(param["name"], param["value"])
        end
        ele.search("variable").each do |param|
          plugin.param_set << Param.new(param["name"], param["value"])
        end
        @plugin_set << plugin
      }

      # parse plugin
      config_doc.xpath('//plugin').each { |ele|
        attrs = get_attributes(ele)

        plugin = Plugin.new(attrs["name"], attrs["spec"] || attrs["version"] || attrs["src"], attrs["platform"], attrs["source"] || "npm")
        ele.search("param").each do |param|
          plugin.param_set << Param.new(param["name"], param["value"])
        end
        ele.search("variable").each do |param|
          plugin.param_set << Param.new(param["name"], param["value"])
        end
        @plugin_set << plugin
      }

      # parse preferences
      config_doc.xpath('//preference').each { |ele|
        next if ele["name"].nil? or ele["name"].empty?
        
        attrs = get_attributes(ele)
        @preference_set << Preference.new(attrs["name"], attrs["value"], attrs["readonly"], attrs["platform"])
      }

      # parse icons
      config_doc.xpath('//icon').each { |ele|
        next if ele["src"].nil? or ele["src"].empty?

        attrs = get_attributes(ele)

        icon_index += 1
        @icon_set << Image.new(attrs["src"], attrs["height"], attrs["width"], attrs, icon_index)
        @plist_icon_set << attrs["src"]
      }

      # parse splashes
      config_doc.xpath('//splash').each { |ele|
        next if ele["src"].nil? or ele["src"].empty?
        
        attrs = get_attributes(ele)

        splash_index += 1
        @splash_set << Image.new(attrs["src"], attrs["height"], attrs["width"], attrs, splash_index)
      }
    end

    # get attributes from the element as well as replace wp8/windows with winphone
    def get_attributes element
      attrs = {}
      element.attributes.each { |k, v| attrs[k] = v.to_s }

      platform = element.parent["name"].to_s if element.parent.name == 'platform'
      if platform.nil?
        platform = element["platform"].nil? ? nil : element["platform"].to_s
      end
      attrs['platform'] = platform.gsub(/^(wp8|windows)$/, "winphone") if !platform.nil?
      attrs
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
    def orientation platform
      values = [:portrait, :landscape, :default]
      choice = preference :orientation, platform

      unless choice and values.include?(choice)
        :default
      else
        choice
      end
    end

    # helper to retrieve a preference's value
    # returns nil if the preference doesn't exist
    def preference name, platform, use_default=true
      pref = preference_object name, platform, use_default

      if pref && pref.value && !pref.value.empty?
        pref.value.to_sym
      end
    end

    # helper to retrieve a preference's value
    # returns nil if the preference doesn't exist
    def preference_object name, platform, use_default=true
      pref = @preference_set.select { |pref| 
        pref.name == name.to_s && pref.platform == platform.to_s 
      }.last
      
      return pref if !use_default

      pref ||= @preference_set.select { |pref| 
        pref.name == name.to_s && pref.platform == nil 
      }.last
    end

    # helper to retrieve all preferences for platform
    def preferences platform
      result=[]
      @preference_set.map{|pref| pref[:name]}.uniq.each { |pref_name|
        pref = preference_object(pref_name, platform)
        result << pref if pref
      }
      result
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
        return icon if icon.src && icon.src =~ /^icon(\.[a-zA-Z0-9]+)+$/i
      end
      nil
    end

    def default_splash
      @splash_set.each do |splash|
        return splash if splash.src && splash.src =~ /^splash(\.[a-zA-Z0-9]+)$/i
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
