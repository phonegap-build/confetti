module Confetti
  module Template
    class FirefoxosManifest < Base

      # See: https://developer.mozilla.org/en-US/Apps/Build/Manifest

      REQUIRED_FIELDS = ['name', 'description', 'launch_path', 'icons',
                         'developer', 'default_locale', 'type']

      OPTIONAL_FIELDS = ['version', 'fullscreen', 'orientation', 'permissions']

      ALL_FIELDS = REQUIRED_FIELDS + OPTIONAL_FIELDS

      # Unhandled / unmappable fields:
      #
      # activities
      # appcache_path
      # chrome
      # csp
      # installs_allowed_from
      # locales
      # messages
      # moz-firefox-accounts
      # origin
      # precompile
      # redirects
      # role

      ORIENTATIONS_MAP = {
        :default    => nil,
        :landscape  => "landscape",
        :portrait   => "portrait"
      }

      GAP_PERMISSIONS_MAP = {
        "camera"        => %w{camera},
        "notification"  => %w{desktop-notification},
        "geolocation"   => %w{geolocation},
        "media"         => %w{audio-capture
                              camera
                              video-capture},
        "contacts"      => %w{contacts},
        "file"          => %w{storage
                              device-storage:videos
                              device-storage:sdcard
                              device-storage:pictures
                              device-storage:music},
        "network"       => %w{mobilenetwork
                              tcp-socket
                              systemXHR},
        "battery"       => %w{}
      }

       # TODO: Need a way to more granularly control access?
      PERMISSIONS_ACCESS_MAP = {
        "contacts" => 'readwrite',
        "storage" => 'readwrite',
        "device-storage:videos" => 'readwrite',
        "device-storage:sdcard" => 'readwrite',
        "device-storage:pictures" => 'readwrite',
        "device-storage:music" => 'readwrite'
      }

      def output_filename
        "manifest.webapp"
      end

      def name
        @config.name.name
      end

      def description
        @config.description
      end

      def version
        @config.version_string || '0.0.1'
      end

      def launch_path
        "index.html"
      end

      def icons
        out = {}
        @config.icon_set.each do |icon|
          out[icon.width] = icon.src
        end
        out
      end

      def developer
        out = {
          "name" => @config.author.name
        }
        out['url'] = @config.author.href if @config.author.href
        out
      end

      def type
        'privileged'
      end

      def default_locale
        'en'
      end

      def fullscreen
        true
      end

      def orientation
        ORIENTATIONS_MAP[@config.orientation]
      end

      def permissions
        names = translate_feature GAP_PERMISSIONS_MAP
        if names.empty?
          out = nil
        else
          out = {}
          names.each do |name|
            out[name] = {
              # TODO: Need to somehow derive a better description?
              "description" => "Required feature"
            }
            out[name]['access'] = PERMISSIONS_ACCESS_MAP[name] if PERMISSIONS_ACCESS_MAP[name]
          end
        end
        out
      end

      def translate_feature map
        features = []
        phonegap_api = /http\:\/\/api.phonegap.com\/1[.]0\/(\w+)/
        feature_names = @config.feature_set.map { |f| f.name }
        feature_names = feature_names - [nil]
        feature_names.sort

        feature_names.each do |f|
          feature_name = f.match(phonegap_api)[1] if f.match(phonegap_api)
          associated_features = map[feature_name]

          features.concat(associated_features) if associated_features
        end

        features.sort!
        features
      end

      # HACK: Override Mustache rendering because JSON is easier & more robust
      def render
        out = {}
        ALL_FIELDS.each do |name|
          val = send(name)
          out[name] = val if val != nil
        end
        JSON.pretty_generate out
      end

    end
  end
end
