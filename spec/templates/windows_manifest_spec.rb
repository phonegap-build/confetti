require 'spec_helper'

describe Confetti::Template::WindowsManifest do
  include HelpfulPaths

  before :all do
    @template_class = Confetti::Template::WindowsManifest
  end

  it "should have the base class of Confetti::Template" do
    @template_class.superclass.should == Confetti::Template::Base
  end

  it "should have a valid appxmanifest mustache template" do
    @template_class.template_file.should == "#{ templates_dir }/windows_manifest.mustache"
  end

  describe "attributes" do
    subject { @template = @template_class.new }
    
    it { should respond_to :title }
    it { should respond_to :author }
    it { should respond_to :guid }
    it { should respond_to :version }
  end

  it "should provide a 128 bit guid" do
    @config = Confetti::Config.new
    @config.package = "com.example.www"
    @template = @template_class.new @config
    @template.guid.should == "1005a3fc-23ab-99bd-bdd1-9e83f3d7b989" 
  end

  describe "with a bad config object" do

    describe "on rendering" do

      it "should generate a dummy uuid if non provided" do
        @config = Confetti::Config.new
        @config.package = "com.example.app"
        @template = @template_class.new @config
        @template.guid.should == "a163ec9b-9996-caee-009d-cdac1b7e0722"
      end
    end
  end

  describe "with a good config object" do

    describe "on rendering" do

      it "should render a valid windows phone appxmanifest" do
        @config = Confetti::Config.new "#{fixture_dir}/config.xml"
        @template = @template_class.new @config
        @template.render.should == File.read(
            "#{fixture_dir}/windows/windows.phone.appxmanifest"
          )
      end

      it "should add a feature when a valid one is found" do
        @config = Confetti::Config.new
        feature = Confetti::Config::Feature.new(
            "http://api.phonegap.com/1.0/geolocation",
            "true"
            )
        @config.feature_set << feature 
        @template = @template_class.new @config
        @template.capabilities.should == [{:name=>"location"}]
      end
    end
  end

  describe "should write a valid manifest file" do

    it "should write the file" do
        @config = Confetti::Config.new
        @config.name.name=""
        @config.feature_set <<
            Confetti::Config::Feature.new(
                "http://plugins.phonegap.com/ChildBrowser/2.0.1",
                'true'
                )
        @config.feature_set <<
            Confetti::Config::Feature.new(
                "http://api.phonegap.com/1.0/geolocation",
                'true'
                )
        @template = @template_class.new @config
        lambda { @template.render }.should_not raise_error
    end
  end

  describe "version" do
    before do
      @config = Confetti::Config.new
      @template = @template_class.new(@config)
    end

    it "should normalize the version to four parts" do
      @config.version_string = "1.0.0"
      @template.version.should == "1.0.0.0"
    end

    it "should allow override with windows_package_version" do
      @config.version_string = "12"
      @template.version.should == "12.0.0.0"
    end

    it "should ensure the non-initial numbers are one digit" do
      # THIS IS STUPID
      @config.version_string = "2012.05.20"
      @template.version.should == "2012.0.2.0"
    end

    it "should ensure letters are converted to numbers" do
      @config.version_string = "1.3.a"
      @template.version.should == "1.3.0.0"
    end
  end

  describe "author" do
    before do
      @config = Confetti::Config.new "spec/fixtures/config.xml"
      @template = @template_class.new(@config)
    end

    it "should return the Confetti Author name in the normal case" do
      @template.author.should == "Andrew Lunny"
    end

    it "should truncate the field to 50 chars or less" do
      me = "Andrew John Lunny, son of William and Vivian, brother of Hugo"
      short = "Andrew John Lunny, son of William and Vivian, brot"
      @config.author.name = me
      @template.author.should == short
    end
  end
end
