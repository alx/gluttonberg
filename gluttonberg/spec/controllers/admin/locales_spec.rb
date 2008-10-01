require File.join( File.dirname(__FILE__), '../..', "spec_helper" )

describe Admin::Locales do
  
  def generate_locale
    3.of { Dialect.generate }
    @locale = Locale.generate
  end
  
  it "should list all locales in index" do
    Locale.all.destroy!
    Dialect.all.destroy!
    
    4.of { Dialect.generate }
    locales = 3.of { Locale.generate }.sort { |x, y| x.name <=> y.name }
    
    controller = dispatch_to(Admin::Locales, :index)
    controller.should be_successful
    controller.assigns(:locales).should == locales
  end
  
  it "should display new form" do
    controller = dispatch_to(Admin::Locales, :new)
    controller.should be_successful
    controller.body.should have_selector("#wrapper form")
  end
  
  it "should display edit form" do
    generate_locale
    controller = dispatch_to(Admin::Locales, :edit, :id => @locale.id)
    controller.should be_successful
    controller.body.should have_selector("#wrapper form")
  end
  
  it "should display delete confirmation" do
    generate_locale
    controller = dispatch_to(Admin::Locales, :delete, :id => @locale.id)
    controller.should be_successful
    controller.body.should have_selector("#delete form")
  end
  
  it "should destroy locale" do
    generate_locale
    controller = dispatch_to(Admin::Locales, :destroy, :id => @locale.id)
    controller.should be_redirection_to("/admin/content/locales")
    Locale.get(@locale.id).should be_nil
  end
  
end

describe Admin::Locales, "create" do
  
  it "should create locale" do
    controller = dispatch_to(Admin::Locales, :create, :locale => {:name => "BO BO BO BO"})
    controller.should be_redirection_to("/admin/content/locales")
  end
  
  it "should display form if create fails" do
    controller = dispatch_to(Admin::Locales, :create, :locale => {:name => ""})
    controller.should be_successful
    controller.body.should have_selector("#wrapper form div.error")
  end
  
end

describe Admin::Locales, "update" do
  
  before :all do
    3.of { Dialect.generate }
    @locale = Locale.generate
  end
  
  it "should update locale" do
    controller = dispatch_to(Admin::Locales, :update, :id => @locale.id, :locale => {:name => "BO BO BO BO"})
    controller.should be_redirection_to("/admin/content/locales")
  end
  
  it "should display form if update fails" do
    controller = dispatch_to(Admin::Locales, :update, :id => @locale.id, :locale => {:name => ""})
    controller.should be_successful
    controller.body.should have_selector("#wrapper form div.error")
  end
  
end