require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module Gluttonberg
  class TestController
    include PublicController
    
    attr_accessor :params
    
    def initialize(params = {})
      @params = params
      set_localization_and_path
    end
  end
  
  # The default case is translated only
  Gluttonberg.stub!(:localized?).and_return(false)
  Gluttonberg.stub!(:translated?).and_return(true)
  
  describe PublicController do
    # Sod fixtures, lets just generate the ones we need.
    Dialect.create(:code => "en", :name => "English")
    Locale.create(:name => "Australia", :slug => "aust")
    
    before :all do
      @dialect = Dialect.first
      @locale = Locale.first
    end
    
    it "should set dialect only" do
      @controller = TestController.new(:dialect => "en", :full_path => "/get/out/now")
      @controller.dialect.should == @dialect
    end
    
    it "should set locale and dialect" do
      Gluttonberg.stub!(:localized?).and_return(true)
      Gluttonberg.stub!(:translated?).and_return(false)
      @controller = TestController.new(:dialect => "en", :locale => "aust", :full_path => "/get/out/now")
      @controller.dialect.should == @dialect
      @controller.locale.should == @locale
    end
    
    it "should cascade to the correct dialect" do
      @controller = TestController.new(:dialect => "en-au", :full_path => "/get/out/now")
      @controller.dialect.should == @dialect
    end
    
    it "should set path" do
      @controller = TestController.new(:dialect => "en", :full_path => "/get/out/now")
      @controller.path.should == "/get/out/now"
    end
  end
end