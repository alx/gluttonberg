require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Gluttonberg::Locale do

  before :all do
    Gluttonberg::Locale.all.destroy!
    Gluttonberg::Dialect.all.destroy!
  end

  it "should swap associated dialects" do
    5.of { Gluttonberg::Dialect.generate }
    
    locale              = Gluttonberg::Locale.generate
    new_dialects        = 3.of { Gluttonberg::Dialect.pick }
    locale.dialect_ids  = new_dialects.collect { |d| d.id }
    
    locale.dialects.each { |d| new_dialects.include?(d).should be_true }
  end

end