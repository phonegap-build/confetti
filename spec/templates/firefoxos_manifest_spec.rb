require 'spec_helper'
require 'json'

describe Confetti::Template::FirefoxosManifest do
  include HelpfulPaths

  before :all do
    @template_class = Confetti::Template::FirefoxosManifest
  end

  it "should inherit from the base template" do
    @template_class.superclass.should be Confetti::Template::Base
  end

  it "should have the template_file \"firefoxos.mustache\" in the confetti/templates dir" do
    @template_class.template_file.should == "#{ templates_dir }/firefoxos_manifest.mustache"
  end

  describe "default values" do
    it "should define output filename as \"manifest.webapp\"" do
      @template_class.new.output_filename.should == "manifest.webapp"
    end
  end

  describe "when passed a config object" do
    before do
      @config = Confetti::Config.new
      @config.name.name = "Awesome App"
      @config.author.name = "Awesome Developer"
      @config.description = "This is an awesome app"

      icon = Confetti::Config::Image.new('icon.png', '128', '128', {}, 0)
      @config.icon_set << icon
    end

    it "should accept the config object" do
      lambda {
        @template_class.new(@config)
      }.should_not raise_error
    end

    describe "templated attributes" do
      before do
        @template = @template_class.new(@config)
      end

      it "should set name correctly" do
        @template.name.should == "Awesome App"
      end

      it "should set description correctly" do
        @template.description.should == "This is an awesome app"
      end

      it "should use the default version" do
        @template.version.should == "0.0.1"
      end

      it "should set developer info correctly" do
        @template.developer['name'] == @config.author.name
        @template.developer.should_not include 'url'
      end

      it "should render the correct web app manifest" do
        expected_json = File.read("#{ fixture_dir }/firefoxos/firefoxos_manifest_spec.json")
        expected = JSON.parse(expected_json)
        result = JSON.parse(@template.render)
        result.should == expected
      end
    end

  end

  it "should populate the manifest with all the icons" do
    @config = Confetti::Config.new("#{fixture_dir}/config-icons.xml")
    @template = @template_class.new(@config)
    result = JSON.parse(@template.render)
    result['icons'].should == {
      "100"=>"smallicon.png",
      "200"=>"bigicon.png"
    }
  end

  it "should handle orientation preference" do
    @config = Confetti::Config.new("#{fixture_dir}/config_with_orientation.xml")
    @template = @template_class.new(@config)

    JSON.parse(@template.render)['orientation'].should == 'landscape'

    @config.preference_set.clear()
    JSON.parse(@template.render).should_not include 'orientation'

    @config.preference_set << Confetti::Config::Preference.new(
      'orientation', 'portrait', false)
    JSON.parse(@template.render)['orientation'].should == 'portrait'
  end

  it "should handle permissions" do
    @config = Confetti::Config.new("#{fixture_dir}/config-features.xml")
    @config.feature_set << Confetti::Config::Feature.new(
      'http://api.phonegap.com/1.0/contacts', false)
    @template = @template_class.new(@config)

    result = JSON.parse(@template.render)
    result['permissions'].should == {
      "desktop-notification" => { "description" => "Required feature" },
      "geolocation" => { "description" => "Required feature" },
      "mobilenetwork" => { "description" => "Required feature" },
      "systemXHR" => { "description" => "Required feature" },
      "tcp-socket" => { "description" => "Required feature" },
      "contacts" => {
        "description" => "Required feature",
        "access" => "readwrite"
      }
    }
  end

end
