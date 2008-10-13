require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module Gluttonberg
  describe Asset, "file upload" do

    @file = File.open(File.join(File.dirname(__FILE__), "..", "fixtures", "gluttonberg_logo.jpg"))
    
    before :all do
      @asset = Asset.new(:file => {:filename => "Gluttonberg Logo.jpg", :content_type => "image/jpg", :size => 300, :tempfile => @file})
    end

    it "should generate filename" do
      @asset.file_name.should_not be_nil
    end
    
    it "should format filename correctly" do
      @asset.file_name.should == "gluttonberg_logo.jpg"
    end
    
    it "should set size" do
      @asset.size.should_not be_nil
    end
    
    it "should set type" do
      @asset.valid?
      @asset.type.should_not be_nil
    end

  end  
end
