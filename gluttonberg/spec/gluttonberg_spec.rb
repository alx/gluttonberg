require File.dirname(__FILE__) + '/spec_helper'

describe Gluttonberg, "config" do
  
  it "should have be localized" do
    Gluttonberg.localized?.should be_true
  end
  
  it "should not be translated" do
    Gluttonberg.translated?.should be_false
  end
  
end

# To spec Gluttonberg you need to hook it up to the router like this:

# before :all do
#   Merb::Router.prepare { add_slice(:Gluttonberg) } if standalone?
# end
# 
# after :all do
#   Merb::Router.reset! if standalone?
# end
