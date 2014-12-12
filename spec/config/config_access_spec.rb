require 'spec_helper'

describe Confetti::Config::Access do
  before do
    @access = Confetti::Config::Access.new
  end

  it "should define a defined_attrs method" do
    access = Confetti::Config::Access.new( "google.ca", true, false, true )

    access.defined_attrs.should == {
      "origin" => "google.ca",
      "subdomains" => true,
      "browserOnly" => false,
      "launchExternal" => true
    }
  end
end
