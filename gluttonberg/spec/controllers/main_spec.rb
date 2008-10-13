require File.dirname(__FILE__) + '/../spec_helper'

describe "Gluttonberg::Main (controller)" do
  
  # Feel free to remove the specs below
  
  before :all do
    Merb::Router.prepare { add_slice(:Gluttonberg) } if standalone?
  end
  
  after :all do
    Merb::Router.reset! if standalone?
  end
  
  it "should have access to the slice module" do
    controller = dispatch_to(Gluttonberg::Main, :index)
    controller.slice.should == Gluttonberg
    controller.slice.should == Gluttonberg::Main.slice
  end
  
  it "should have an index action" do
    controller = dispatch_to(Gluttonberg::Main, :index)
    controller.status.should == 200
    controller.body.should contain('Gluttonberg')
  end
  
  it "should work with the default route" do
    controller = get("/gluttonberg/main/index")
    controller.should be_kind_of(Gluttonberg::Main)
    controller.action_name.should == 'index'
  end
  
  it "should work with the example named route" do
    controller = get("/gluttonberg/index.html")
    controller.should be_kind_of(Gluttonberg::Main)
    controller.action_name.should == 'index'
  end
    
  it "should have a slice_url helper method for slice-specific routes" do
    controller = dispatch_to(Gluttonberg::Main, 'index')
    
    url = controller.url(:gluttonberg_default, :controller => 'main', :action => 'show', :format => 'html')
    url.should == "/gluttonberg/main/show.html"
    controller.slice_url(:controller => 'main', :action => 'show', :format => 'html').should == url
    
    url = controller.url(:gluttonberg_index, :format => 'html')
    url.should == "/gluttonberg/index.html"
    controller.slice_url(:index, :format => 'html').should == url
    
    url = controller.url(:gluttonberg_home)
    url.should == "/gluttonberg/"
    controller.slice_url(:home).should == url
  end
  
  it "should have helper methods for dealing with public paths" do
    controller = dispatch_to(Gluttonberg::Main, :index)
    controller.public_path_for(:image).should == "/slices/gluttonberg/images"
    controller.public_path_for(:javascript).should == "/slices/gluttonberg/javascripts"
    controller.public_path_for(:stylesheet).should == "/slices/gluttonberg/stylesheets"
    
    controller.image_path.should == "/slices/gluttonberg/images"
    controller.javascript_path.should == "/slices/gluttonberg/javascripts"
    controller.stylesheet_path.should == "/slices/gluttonberg/stylesheets"
  end
  
  it "should have a slice-specific _template_root" do
    Gluttonberg::Main._template_root.should == Gluttonberg.dir_for(:view)
    Gluttonberg::Main._template_root.should == Gluttonberg::Application._template_root
  end

end