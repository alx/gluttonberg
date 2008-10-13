require File.join( File.dirname(__FILE__), '../..', "spec_helper" )

module Templating
  def template(opts)
    template = {
      :name       => "Default Template",
      :file_name  => "default",
      :type       => "view",
      :format     => "html",
      :language   => "haml"
    }
    template[:name] = '' if !opts[:valid]
    template
  end
end

describe Admin::Templates do
  
  it "should display layouts and views in index" do
    sorter = lambda { |x, y| x.name <=> y.name }
    
    layouts = 3.of  { Template.generate(:layout) }.sort(&sorter)
    views   = 10.of { Template.generate(:view) }.sort(&sorter)
    
    controller = dispatch_to(Admin::Templates, :index)
    controller.should be_successful
    controller.assigns(:layouts).should == layouts
    controller.assigns(:templates).should == views
  end
  
  it "should destroy the template" do
    layout = Template.generate(:layout)
    controller = dispatch_to(Admin::Templates, :destroy, :id => layout.id)
    
    controller.should be_redirection_to("/admin/content/templates")
    Template.get(layout.id).should be_nil
  end
  
  it "should display new form" do
    controller = dispatch_to(Admin::Templates, :new)
    controller.should be_successful
    controller.body.should have_selector("#wrapper form")
  end
  
  it "should display edit form" do
    view = Template.generate(:view)
    controller = dispatch_to(Admin::Templates, :edit, :id => view.id)
    controller.should be_successful
    controller.body.should have_selector("#wrapper form")
  end
  
  it "should display delete confimation" do
    view = Template.generate(:view)
    controller = dispatch_to(Admin::Templates, :delete, :id => view.id)
    controller.should be_successful
    controller.body.should have_selector("#delete form")
  end
  
end

describe Admin::Templates, "update" do
  include Templating
  
  before :all do
    Template.all.destroy!
    @template = Template.generate(:view)
  end
  
  it "should update and redirect" do
    controller = dispatch_to(Admin::Templates, :update, :id => @template.id, :template => template(:valid => true))
    controller.should be_redirection_to("/admin/content/templates")
  end
  
  it "should display form if update fails" do
    controller = dispatch_to(Admin::Templates, :update, :id => @template.id, :template => template(:valid => false))
    controller.should be_successful
    controller.body.should have_selector("#wrapper form")
    controller.body.should have_selector("#wrapper form div.error")
  end
  
end

describe Admin::Templates, "create" do
  include Templating
  
  it "should create and redirect" do
    controller = dispatch_to(Admin::Templates, :create, :template => template(:valid => true))
    controller.should be_redirection_to("/admin/content/templates")
  end
  
  it "should display form if create fails" do
    controller = dispatch_to(Admin::Templates, :create, :template => template(:valid => false))
    controller.should be_successful
    controller.body.should have_selector("#wrapper form")
    controller.body.should have_selector("#wrapper form div.error")
  end
  
end