require File.join( File.dirname(__FILE__), '../..', "spec_helper" )

module Gluttonberg
  module Library
    describe Assets do
      
      before :all do
        Asset.all.destroy!
      end
      
      it "should display pages in index" do
        10.of { Asset.generate }
        controller = dispatch_to(Assets, :index)
        controller.should be_successful
      end
      
      it "should show page" do
        asset = Asset.generate
        controller = dispatch_to(Assets, :show, :id => asset.id)
        controller.should be_successful
        controller.assigns(:asset).should == asset
      end
      
      it "should display edit form" do
        asset = Asset.generate
        controller = dispatch_to(Assets, :edit, :id => asset.id)
        controller.should be_successful
        controller.assigns(:asset).should == asset
      end
      
      it "should display new form" do
        controller = dispatch_to(Assets, :new)
        controller.should be_successful
      end
      
      it "should display delete confirmation" do
        asset = Asset.generate
        controller = dispatch_to(Assets, :delete, :id => asset.id)
        controller.should be_successful
        controller.assigns(:asset).should == asset
      end
      
      it "should destroy asset" do
        asset = Asset.generate
        controller = dispatch_to(Assets, :destroy, :id => asset.id)
        Asset.get(asset.id).should be_nil
      end
    end
    
    describe Asset, "create" do
      it "should create asset"
      
      it "should display error if create fails"
    end
    
    describe Asset, "update" do
      it "should update asset"
      
      it "should display error if update fails"
    end
  end
end