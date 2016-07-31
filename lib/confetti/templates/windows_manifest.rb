module Confetti
  module Template
    class WindowsManifest < Base
      include VersionHelper

      def title
        @config.name.name.strip
      end

      def package_identifier
        val = title.gsub(/[^\.a-z0-9]/i, '')
        val = "app" if val == ""
        val = "app.#{val}" if val[0] !~ /[a-z]/i
        val
      end

      def author
        @config.author.name ? @config.author.name[0..49] : ""
      end

      def identity_name
        pref = @config.preference("windows-identity-name", :windows)
        if !pref.nil?
          pref
        else
          "#{ author }.#{ title }".gsub(/[^-\.a-z0-9]/i, '')
        end
      end

      def guid
        package = @config.package
        package ||= 'com.example.app'
        generate_guid package
      end
      
      def producerguid
        if @config.windows_publisher_id
          @config.windows_publisher_id
        else
          package = @config.package
          package ||= 'com.example.app'
          package = "#{package}" + "second";
          generate_guid package
        end
      end

      def generate_guid val
        guid = Digest::MD5.hexdigest val 
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

    end
  end
end