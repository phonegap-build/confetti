module Confetti
  module Template
    class WindowsManifest < Base
      include VersionHelper


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

    end
  end
end