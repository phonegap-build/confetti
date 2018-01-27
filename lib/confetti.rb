CURRENT_DIR = File.dirname(__FILE__)

# stdlib
require 'nokogiri'
require 'digest/md5'
require 'mini_magick'
require 'image_optimizer'
require 'open3'
ImageOptimizer.quiet = true

# external dependencies
begin
  require "bundler/setup"
rescue LoadError
  require "rubygems"
  require "bundler/setup"
end

require "mustache"
require 'versionomy'

# internal dependencies
require 'typedset'
require 'confetti/version'
require 'confetti/error'
require 'confetti/helpers'

require 'confetti/template'
require 'confetti/templates/base'
require 'confetti/templates/java_checks'
require 'confetti/templates/version_helper'

require 'confetti/templates/android_manifest'
require 'confetti/templates/android_strings'
require 'confetti/templates/ios_info'
require 'confetti/templates/ios_remote_plist'
require 'confetti/templates/windows_phone8_manifest'
require 'confetti/templates/windows_manifest'

require 'confetti/template_helper'

require 'confetti/config/classes'
require 'confetti/phonegap/plugin'
require 'confetti/phonegap'
require 'confetti/config'
require 'confetti/config/feature'
require 'confetti/config/image'
require 'confetti/config/url_scheme'

require 'confetti/resizer'
require 'util/safe_sys'
