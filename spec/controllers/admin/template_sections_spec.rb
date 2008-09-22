require File.join( File.dirname(__FILE__), '../..', "spec_helper" )

describe Admin::TemplateSections do
  def generate_section
    @section   = TemplateSection.generate
    @template  = Template.generate(:view)
    @template.update_attributes(:sections => [@section])
  end
  
  
  it "should have index action display sections for template" do
    view      = Template.generate(:view)
    sections  = 3.of { TemplateSection.generate }
    view.update_attributes(:sections => sections)
    controller = dispatch_to(Admin::TemplateSections, :index, :template_id => view.id)
    
    controller.should be_successful
    controller.assigns(:template).should == view
    controller.assigns(:sections).should == sections
  end
  
  it "should display new form" do
    template = Template.generate(:view)
    controller = dispatch_to(Admin::TemplateSections, :new, :template_id => template.id)
    
    controller.should be_successful
    controller.body.should have_selector("#wrapper form")
  end
  
  it "should display edit form" do
    generate_section
    controller = dispatch_to(Admin::TemplateSections, :edit, :id => @section.id, :template_id => @template.id)
    
    controller.should be_successful
    controller.assigns(:template_section).should == @section
    controller.body.should have_selector("#wrapper form")
  end
  
  it "should display delete confirmation" do
    generate_section
    controller = dispatch_to(Admin::TemplateSections, :delete, :id => @section.id, :template_id => @template.id)
    
    controller.should be_successful
    controller.assigns(:template_section).should == @section
    controller.body.should have_selector("#delete form")
  end
  
end

module TemplateSectionsSpecHelpers
  def template_section(opts)
    section = {
      :label  => "Main body",
      :name   => "main",
      :type   => "article"
    }
    section[:name] = '' if !opts[:saves]
    section
  end
end

describe Admin::TemplateSections, "create" do
  include TemplateSectionsSpecHelpers
  
  it "should create template section" do
    template = Template.generate(:view)
    controller = dispatch_to(Admin::TemplateSections, :create, :template_id => template.id, :template_section => template_section(:saves => true))
    controller.should be_redirection_to("/admin/content/templates/#{template.id}/sections")
  end
  
  it "should display form if create fails" do
    template = Template.generate(:view)
    controller = dispatch_to(Admin::TemplateSections, :create, :template_id => template.id, :template_section => template_section(:saves => false))
    controller.should be_successful
    controller.body.should have_selector("#wrapper form")
    controller.body.should have_selector("#wrapper form div.error")
  end
  
end

describe Admin::TemplateSections, "update" do
  include TemplateSectionsSpecHelpers
  
  before :all do
    @section = TemplateSection.generate
    @template = Template.generate(:view)
    @template.update_attributes(:sections => [@section])
  end
  
  def dispatch(opts)
    dispatch_to(
      Admin::TemplateSections, 
      :create, 
      :id               => @section.id,
      :template_id      => @template.id, 
      :template_section => template_section(:saves => opts[:saves])
    )
  end
  
  it "should update template section" do
    controller = dispatch(:saves => true)
    
    controller.should be_redirection_to("/admin/content/templates/#{@template.id}/sections")
  end
  
  it "should display form if update fails" do
    controller = controller = dispatch(:saves => false)
    
    controller.should be_successful
    controller.body.should have_selector("#wrapper form")
    controller.body.should have_selector("#wrapper form div.error")
  end
  
end