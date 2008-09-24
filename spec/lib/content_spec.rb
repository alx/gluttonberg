require File.join( File.dirname(__FILE__), '..', "spec_helper" )

class SuperContent
  include DataMapper::Resource
  include Glutton::Content::Block
  
  property :id, Serial
  
  has_localizations :super_content_localizations
end

class SuperContentLocalization
  include DataMapper::Resource
  include Glutton::Content::Localization
  
  property :id, Serial
  
  localizes :super_content
end

class WeakContent
  include DataMapper::Resource
  include Glutton::Content::Block
  
  property :id, Serial
end

describe Glutton::Content do
  it "should have registered content classes" do
    Glutton::Content.content_classes.include?(SuperContent).should be_true
  end
  
  it "should have registered content associations" do
    Glutton::Content.content_associations.include?(:super_contents).should be_true
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
  it "should define properties" do
    properties = SuperContentLocalization.properties.collect {|k| k.name}
    [:created_at, :updated_at].each do |property|
      properties.include?(property).should be_true
    end
  end
  
  it "should belong to content block" do
    relationships = SuperContentLocalization.relationships.keys
    relationships.include?(:parent).should be_true
  end
  
  it "should belong to page localization" do
    relationships = SuperContentLocalization.relationships.keys
    relationships.include?(:localization).should be_true
  end
end