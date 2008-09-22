require File.join( File.dirname(__FILE__), '../..', "spec_helper" )

describe Admin::Content do
  
  it "should render index" do
    controller = dispatch_to(Admin::Content, :index)
    controller.should be_successful
  end
  
end