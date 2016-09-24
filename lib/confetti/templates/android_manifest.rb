module Confetti
  module Template
    class AndroidManifest < Base
      include JavaChecks

      ORIENTATIONS_MAP = {
        :default    => "unspecified",
        :landscape  => "landscape",
        :portrait => "portrait"
      }

      def package_name
        convert_to_java_package_id(@config.package)
      end

      def class_name
        convert_to_java_identifier(@config.name.name) if @config
      end

      def output_filename
        "AndroidManifest.xml"
      end

      def version
        @config.version_string || '0.0.1'
      end

      def version_code
        config_version_code = @config.preference("android-versionCode", :android) || 
          @config.android_versioncode || 
          @config.version_code ||
          "1"
          
        (config_version_code =~ /\A\d+\Z/) ? config_version_code.to_s : "1"
      end

      def app_orientation
        ORIENTATIONS_MAP[@config.orientation(:android)]
      end

      def install_location
        valid_choices = %w(internalOnly auto preferExternal)
        choice = @config.preference("android-installLocation", :android).to_s

        valid_choices.include?(choice) ? choice : "internalOnly"
      end

      def min_sdk_version_attribute
        choice = @config.preference("android-minSdkVersion", :android) || @config.default_min_sdk

        if int_value?(choice)
          "android:minSdkVersion=\"#{ choice }\" "
        end
      end

      def max_sdk_version_attribute
        choice = @config.preference("android-maxSdkVersion", :android)

        if int_value?(choice)
          "android:maxSdkVersion=\"#{ choice }\" "
        end
      end

      def target_sdk_version_attribute
        choice = @config.preference("android-targetSdkVersion", :android)

        if int_value?(choice)
          "android:targetSdkVersion=\"#{ choice }\" "
        end
      end

      def window_soft_input_mode
        choice = @config.preference("android-windowSoftInputMode", :android).to_s

        choice == "" ? "stateUnspecified|adjustUnspecified" : choice
      end

      def int_value? val
        return if val.nil?

        integer = /^\d+$/
        val.to_s.match(integer)
      end
    end
  end
end
