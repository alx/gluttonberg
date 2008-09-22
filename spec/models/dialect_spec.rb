require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Dialect do

  it "should return correct name and code" do
    dialect = Dialect.create(:name => "English", :code => "en")
    dialect.name_and_code.should == "English (en)"
  end

end