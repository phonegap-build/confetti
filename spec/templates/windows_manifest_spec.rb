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
        @template.template = File.read("./lib/confetti/templates/package.phone.appxmanifest.mustache")
        @template.render.should == File.read(
            "#{fixture_dir}/windows/windows.phone.appxmanifest"
          )
      end
    end
  end

  describe "should write a valid manifest file" do

    before do
      @output_manifest = File.expand_path("#{fixture_dir}/windows/output.appxmanifest")
      @expected_manifest = File.expand_path("#{fixture_dir}/windows/windows.phone.appxmanifest")
      @config = Confetti::Config.new "#{fixture_dir}/config.xml"
    end

    it "should write the file" do
        @config.write_windows_manifest @output_manifest, "package.phone.appxmanifest"
        File.read(@output_manifest).should == File.read(@expected_manifest)
    end

    after do
      FileUtils.rm(@output_manifest)
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

    it "should ensure letters are converted to numbers" do
      @config.version_string = "1.3.a"
      @template.version.should == "1.3.0.0"
    end

    it "should use windows_package_version if present" do
      @config.windows_package_version = "a-version-string"
      @template.version.should == "a-version-string"
    end
  end

  describe "package_identifier" do
    before do
      @config = Confetti::Config.new "spec/fixtures/config.xml"
    end

    it "should return packageName from config.xml if present" do
      @config.instance_variable_set(:@windows_package_name, 'ConfigPackageName')
      @template = @template_class.new(@config)
      @template.package_identifier.should == "ConfigPackageName"
    end

    it "should return the default from the title" do
      @template = @template_class.new(@config)
      @template.package_identifier.should == "ConfettiSampleApp"
    end

    it "should strip illegal characters from the default" do
      @config.instance_variable_set(:@name, Confetti::Config::Name.new('12is.a.windows-%^$#{ %}_dev !'))
      @template = @template_class.new(@config)
      @template.package_identifier.should == 'isawindowsdev'
    end
  end

  describe "identity_name" do
    before do
      @config = Confetti::Config.new "spec/fixtures/config.xml"
    end

    it "should return the identity_name from the preference" do
      @config.preference_set << Confetti::Config::Preference.new("windows-identity-name", "lunny-dev")
      @template = @template_class.new(@config)
      @template.identity_name.should == :"lunny-dev"
    end

    it "should return the default from the author and title if no preference" do
      @template = @template_class.new(@config)
      @template.identity_name.should == "AndrewLunny.ConfettiSampleApp"
    end

    it "should strip illegal characters from the default" do
      @config.instance_variable_set(:@name, Confetti::Config::Name.new('is.a.windows-%^$#{ %}_dev !'))
      @template = @template_class.new(@config)
      @template.identity_name.should == 'AndrewLunny.isawindows-dev'
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

    it "should return default if author not present" do
      @config.instance_variable_set(:@author, Confetti::Config::Author.new)
      @template.author.should == "Default Publisher Name"
    end

    it "should truncate the field to 50 chars or less" do
      me = "Andrew John Lunny, son of William and Vivian, brother of Hugo"
      short = "Andrew John Lunny, son of William and Vivian, brot"
      @config.author.name = me
      @template.author.should == short
    end
  end
end
