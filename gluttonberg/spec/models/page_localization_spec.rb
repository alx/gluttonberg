require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe PageLocalization do

  it "should cache new path" do
    page = Page.generate(:no_templates)
    localization = PageLocalization.new(:slug => "sales", :page => page)
    localization.cache_path!("/about/staff")
    
    localization.path.should == "/about/staff/sales"
  end

  it "should return correct name and code" do
    dialect = Dialect.generate(:code => "en")
    locale  = Locale.generate(:name => "South Australia", :dialects => [dialect])
    
    localization = PageLocalization.new(:slug => "sales", :name => "Sales", :locale => locale, :dialect => dialect)
    
    localization.name_and_code.should == "Sales (South Australia/en)"
  end

end