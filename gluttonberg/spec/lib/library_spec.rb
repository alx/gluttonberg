require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module Gluttonberg
  
  Library.setup
  
  describe Library do
    it "should have asset root set" do
      Library.assets_dir.should == Merb.dir_for(:public) / "assets"
    end
    
    it "should have asset subdirectories" do
      Library::TYPES.each do |type|
        plural = type.to_s.pluralize
        path = Merb.dir_for(:public) / "assets" / plural
        
        File.exists?(path).should be_true
        Library.assets_dir(plural.to_sym).should == path
      end
    end
  end
end