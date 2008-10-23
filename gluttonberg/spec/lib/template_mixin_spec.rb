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
      @template.templates.is_a?(Array).should be_true
    end
    
    it "should capture formats" do
      counts = @template.templates.inject({}) do |memo, template|
        (memo[template[:format]] ||= 0)
        memo[template[:format]] += 1
        memo
      end
      counts["html"].should == 2
      counts["xml"].should == 1
      counts["yml"].should == 1
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
       @template.templates.is_a?(Array).should be_true
    end
  end
  
  describe TemplateMixin, "vanilla" do
    before :all do
      Gluttonberg.stub!(:localized?).and_return(false)
      Gluttonberg.stub!(:translated?).and_return(false)
    end
  end
end