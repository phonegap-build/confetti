require 'spec_helper'

describe Confetti::Config::Platform do
  before do
    @platform = Confetti::Config::Platform.new("ios","3.7.0")
  end

  it "should have a readable and writable name field" do
    lambda { @platform.name = "ios" }.should_not raise_error
    @platform.name.should == "ios"
  end

  it "should have a readable and writable phonegap-version field" do
    lambda { @platform.phonegap_version = "3.7.0" }.should_not raise_error
    @platform.phonegap_version.should == "3.7.0"
  end

  it "should define a defined_attrs method" do
    platform = Confetti::Config::Platform.new("ios","3.7.0")
    
    platform.defined_attrs.should == {
      "name" => "ios",
      "phonegap-version" => "3.7.0"
    }
  end
end
