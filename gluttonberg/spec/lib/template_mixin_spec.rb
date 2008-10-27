require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module Gluttonberg
  class TemplateMixinTest
    include TemplateMixin
    
    def filename
      "default"
    end
    
    def template_glob
      File.join(File.dirname(__FILE__), "..", "fixtures", "templates", "layouts/*")
    end
    
    def self.template_dir
      File.join(File.dirname(__FILE__), "..", "fixtures", "templates", "layouts")
    end
  end
  
  # Create the dialects and locales we need
  dialect = Dialect.create(:code => "en-au", :name => "English")
  Locale.create(:name => "Australia", :slug => "aust", :dialects => [dialect])
  Locale.create(:name => "South Australia", :slug => "sth-aust", :dialects => [dialect])
  
  describe TemplateMixin, "localized" do
    before :all do
      Gluttonberg.stub!(:localized?).and_return(true)
      
      @template = TemplateMixinTest.new
      @dialect = Dialect.first
      @aust = Locale.first(:slug => "aust")
      @south_aust = Locale.first(:slug => "sth-aust")
    end
    
    it "should return list of templates" do
      @template.templates.should_not be_nil
      @template.templates.is_a?(Hash).should be_true
    end
    
    it "should return a matching template for html" do
      html = @template.template_for(:dialect => @dialect, :locale => @aust)
      html.should_not be_nil
      html.match(/default.aust.en-au/).should_not be_nil
    end
    
    it "should return a default template for html" do
      html = @template.template_for(:dialect => @dialect, :locale => @south_aust)
      html.should_not be_nil
      html.match(/default/).should_not be_nil
    end
  end
  
  describe TemplateMixin, "translated" do
    before :all do
      Gluttonberg.stub!(:localized?).and_return(false)
      Gluttonberg.stub!(:translated?).and_return(true)
      
      @template = TemplateMixinTest.new
    end
    
    it "should return list of templates" do
       @template.templates.should_not be_nil
       @template.templates.is_a?(Hash).should be_true
    end
  end
  
  describe TemplateMixin, "default" do
    before :all do
      Gluttonberg.stub!(:localized?).and_return(false)
      Gluttonberg.stub!(:translated?).and_return(false)
      
      @template = TemplateMixinTest.new
    end
    
    it "should return default template" do
      template = @template.template_for({})
      template.match(/default/).should_not be_nil
    end
  end
end