module Confetti
  module Template
    class WindowsManifest < Base
      include VersionHelper

      GAP_PERMISSIONS_MAP = {
        'camera' => %w{webcam},
        'contacts' => %w{contacts},
        'geolocation' => %w{location},
        'network' => %w{internetClient},
        'media' => %w{microphone},
      }

      def title
        @config.name.name.gsub(/\s+/, "")
      end

      def author
        @config.author.name ? @config.author.name[0..49] : ""
      end

      def guid
        package = @config.package
        package ||= 'com.example.app'
        guid = Digest::MD5.hexdigest package 
        res = "#{ guid[0..7] }-#{ guid[8..11] }-"
        res << "#{ guid[12..15] }-#{ guid[16..19] }-"
        res << "#{ guid[20,guid.length-1]}"
      end
      
      def producerguid
        package = @config.package
        package ||= 'com.example.app'
        package = "#{package}" + "second";
        guid = Digest::MD5.hexdigest package 
        res = "#{ guid[0..7] }-#{ guid[8..11] }-"
        res << "#{ guid[12..15] }-#{ guid[16..19] }-"
        res << "#{ guid[20,guid.length-1]}"
      end

      def version
        v = normalize_version(@config.version_string).split('.')

        # after the first one, each segment can only have one character
        "#{ v[0] }.#{ v[1][0..0] }.#{ v[2][0..0] }.0"
      end

      def output_filename 
        "package.phone.appxmanifest"
      end

      def capabilities
        default_permissions = %w{}
        permissions = []                                                
        capabilities = []                                                
        phonegap_api = /http\:\/\/api.phonegap.com\/1[.]0\/(\w+)/          
        filtered_features = @config.feature_set.clone

        filtered_features.each { |f|
            next if f.name.nil?
            matches = f.name.match(phonegap_api)
            next if matches.nil? or matches.length < 1 
            next unless GAP_PERMISSIONS_MAP.has_key?(matches[1])
            permissions << matches[1]
        }

        if @config.feature_set.empty? and
            @config.preference(:permissions, :winphone) != :none
            permissions = default_permissions
        end

        permissions.each { |p|
            capabilities.concat(GAP_PERMISSIONS_MAP[p])
        }
      
        capabilities.sort! 
        capabilities.map { |f| { :name => f } }
      end

    end
  end
end