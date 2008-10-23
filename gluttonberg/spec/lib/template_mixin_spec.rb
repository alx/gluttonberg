require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module Gluttonberg
  class TemplateMixinTest
    include TemplateMixin
    
    def filename
      "default"
    end
    
    def template_glob
      "/imaginary/path/to/templates"
    end
  end
  
  describe TemplateMixin, "localized" do
    before :all do
      Gluttonberg.stub!(:localized?).and_return(true)
      Dir.stub!(:glob).and_return([
        "/path/to/default.html.haml", 
        "/path/to/default.aust.en-au.html.haml", 
        "/path/to/default.spain.es.html.haml",
        "/path/to/default.aust.en-au.xml.haml",
        "/path/to/default.aust.en-au.yml.haml"
      ])
      
      @template = TemplateMixinTest.new
    end
    
    it "should have default" do
      @template.templates
      @template.has_default?.should be_true
    end
    
    it "should return list of templates" do
      @template.templates.should_not be_nil
      @template.templates.is_a?(Hash).should be_true
    end
  end
  
  describe TemplateMixin, "translated" do
    before :all do
      Gluttonberg.stub!(:localized?).and_return(false)
      Gluttonberg.stub!(:translated?).and_return(true)
      Dir.stub!(:glob).and_return([
        "/path/to/default.html.haml", 
        "/path/to/default.en-au.html.haml", 
        "/path/to/default.es.html.haml",
        "/path/to/default.en-au.xml.haml",
        "/path/to/default.en-au.yml.haml"
      ])
      
      @template = TemplateMixinTest.new
    end
    
    it "should have default" do
      @template.templates
      @template.has_default?.should be_true
    end
    
    it "should return list of templates" do
       @template.templates.should_not be_nil
       @template.templates.is_a?(Hash).should be_true
    end
  end
  
  describe TemplateMixin, "vanilla" do
    before :all do
      Gluttonberg.stub!(:localized?).and_return(false)
      Gluttonberg.stub!(:translated?).and_return(false)
    end
  end
end