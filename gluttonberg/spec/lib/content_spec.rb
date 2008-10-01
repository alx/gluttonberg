require File.join( File.dirname(__FILE__), '..', "spec_helper" )

# Classes used just for this particular test
class SuperContent
  include DataMapper::Resource
  include Glutton::Content::Block
  
  property :id, Serial
  
  is_localized do
    property :text, Text
  end
end

class WeakContent
  include DataMapper::Resource
  include Glutton::Content::Block
  
  property :id, Serial
end

# Run setup again so it picks up the classes defined above
Glutton::Content.setup

describe Glutton::Content do
  it "should have registered content classes" do
    Glutton::Content.content_classes.include?(SuperContent).should be_true
  end
  
  it "should have registered content associations" do
    Glutton::Content.content_associations.include?(:super_contents).should be_true
  end
  
  it "should create associations for Page and TemplateSection models" do
    puts Page.relationships.keys
    [Page, TemplateSection].each do |klass|
      klass.relationships[:super_contents].should_not be_nil
      klass.relationships[:weak_contents].should_not be_nil
    end
  end
end

describe Glutton::Content::Block do
  it "should define properties" do
    properties = SuperContent.properties.collect {|k| k.name}
    [:orphaned, :created_at, :updated_at].each do |property|
      properties.include?(property).should be_true
    end
  end
  
  it "should be localized" do
    SuperContent.localized?.should be_true
  end
  
  it "should have localization association" do
    relationships = SuperContent.relationships.keys
    relationships.include?(:localizations).should be_true
  end
  
  it "should not be localized" do
    WeakContent.localized?.should be_false
  end
  
  it "should belong to section" do
    relationships = SuperContent.relationships.keys
    relationships.include?(:section).should be_true
  end
end

describe Glutton::Content::Localization do
  it "should create localization model" do
    SuperContent.constants.include?("Localization").should be_true
  end
  
  it "should define properties" do
    properties = SuperContent::Localization.properties.collect {|k| k.name}
    [:created_at, :updated_at].each do |property|
      properties.include?(property).should be_true
    end
  end
  
  it "should belong to content block" do
    relationships = SuperContent::Localization.relationships.keys
    relationships.include?(:parent).should be_true
  end
  
  it "should belong to page localization" do
    relationships = SuperContent::Localization.relationships.keys
    relationships.include?(:page_localization).should be_true
  end
end