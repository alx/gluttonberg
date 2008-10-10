require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module Gluttonberg
  describe Page do

    before(:all) do
      Page.all.destroy!
      Template.all.destroy!
    end

    it "should return correct localization"

    it "should raise error if locale is missing"

    it "should return default layout_name" do
      page = Page.generate(:no_templates)
      page.layout_name.should == "public"
    end

    it "should return cached layout_name" do
      page    = Page.generate(:no_templates)
      layout  = Template.generate(:layout)

      page.update_attributes(:layout => layout)

      page.layout_name.should == layout.name
    end

    it "should return default template_name" do
      page = Page.generate(:no_templates)
      page.template_name.should == "default"
    end

    it "should return cached template_name" do
      page      = Page.generate(:no_templates)
      template  = Template.generate(:view)

      page.update_attributes(:template => template)

      page.template_name.should == template.name
    end

    it "should have only one home page at a time" do
      Template.generate(:layout)
      Template.generate(:view)
      4.of { Page.generate(:parent) }
      new_home = Page.pick(:parent)
      current_home = Page.generate(:parent, :home => true)

      new_home.update_attributes(:home => true)

      new_home.reload
      current_home.reload

      new_home.home.should be_true
      current_home.home.should be_false
    end

  end
end
