require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module Gluttonberg
  describe Template do

    before :all do
      Template.all.destroy!
    
      6.of { Template.generate(:layout) }
      4.of { Template.generate(:view) }
    end

    it "should return layouts only" do
      layouts = Template.layouts
    
      layouts.length.should == 6
      layouts.each { |layout| layout.type.should == :layout }
    end
  
    it "should return views only" do
      views = Template.views

      views.length.should == 4
      views.each { |view| view.type.should == :view }
    end

  end  
end
