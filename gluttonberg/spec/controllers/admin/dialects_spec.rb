require File.join( File.dirname(__FILE__), '../..', "spec_helper" )

describe Admin::Dialects do
  
  it "should list dialects in index" do
    Dialect.all.destroy!
    
    dialects = 10.of { Dialect.generate }
    controller = dispatch_to(Admin::Dialects, :index)
    controller.should be_successful
    dialects.each do |dialect| 
      controller.assigns(:dialects).include?(dialect).should == true 
    end
  end
  
  it "should display new form" do
    controller = dispatch_to(Admin::Dialects, :new)
    controller.should be_successful
    controller.body.should have_selector("#wrapper form")
  end
  
  it "should display edit form" do
    dialect = Dialect.generate
    controller = dispatch_to(Admin::Dialects, :edit, :id => dialect.id)
    controller.should be_successful
    controller.body.should have_selector("#wrapper form")
    controller.assigns(:dialect).should == dialect
  end
  
  it "should display delete confirmation" do
    dialect = Dialect.generate
    controller = dispatch_to(Admin::Dialects, :delete, :id => dialect.id)
    controller.should be_successful
    controller.body.should have_selector("#delete form")
  end
  
  it "should destroy dialect" do
    dialect = Dialect.generate
    controller = dispatch_to(Admin::Dialects, :destroy, :id => dialect.id)
    controller.should be_redirection_to("/admin/content/dialects")
    Dialect.get(dialect.id).should be_nil
  end
  
end

module AdminDialectsSpecHelper
  def dialect(opts)
    dialect = {:code => "en", :name => "English"}
    dialect[:name] = '' if !opts[:saves]
    dialect
  end
end

describe Admin::Dialects, "create" do
  include AdminDialectsSpecHelper
  
  it "should create dialect" do
    controller = dispatch_to(Admin::Dialects, :create, :dialect => dialect(:saves => true))
    controller.should be_redirection_to("/admin/content/dialects")
  end
  
  it "should display form if create fails" do
    controller = dispatch_to(Admin::Dialects, :create, :dialect => dialect(:saves => false))
    controller.should be_successful
    controller.body.should have_selector("#wrapper form div.error")
  end
  
end

describe Admin::Dialects, "edit" do
  include AdminDialectsSpecHelper
  
  before :all do
    @dialect = Dialect.generate
  end
  
  it "should update dialect" do
    controller = dispatch_to(Admin::Dialects, :update, :id => @dialect.id, :dialect => dialect(:saves => true))
    controller.should be_redirection_to("/admin/content/dialects")
  end
  
  it "should display form if update fails" do
    controller = dispatch_to(Admin::Dialects, :update, :id => @dialect.id, :dialect => dialect(:saves => false))
    controller.should be_successful
    controller.body.should have_selector("#wrapper form div.error")
  end
  
end