# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "confetti/version"

Gem::Specification.new do |s|
  s.name        = "confetti"
  s.version     = Confetti::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andrew Lunny", "Filip Maj", "Hardeep Shoker", "Brett Rudd", "Ryan Willoughby"]
  s.email       = ["alunny@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/confetti"
  s.summary     = %q{Generate mobile app config files}
  s.description = %q{ A little library to generate platform-specific mobile app
                      configuration files from a W3C widget spec compliant config.xml}

  s.rubyforge_project = "confetti"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency "mustache", "~> 0.11.2"
  s.add_dependency "nokogiri", "~> 1.8.2"
  s.add_dependency "versionomy", "~> 0.5.0"
  s.add_dependency "mini_magick", "~> 4.8.0"
  s.add_dependency "image_optimizer", "~> 1.7.2"

  s.add_development_dependency "rspec", "~> 2.6.0"
end
