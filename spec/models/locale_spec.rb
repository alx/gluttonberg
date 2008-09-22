require File.join( File.dirname(__FILE__), '..', "spec_helper" )

describe Locale do

  before :all do
    Locale.all.destroy!
    Dialect.all.destroy!
  end

  it "should swap associated dialects" do
    5.of { Dialect.generate }
    
    locale              = Locale.generate
    new_dialects        = 3.of { Dialect.pick }
    locale.dialect_ids  = new_dialects.collect { |d| d.id }
    
    locale.dialects.each { |d| new_dialects.include?(d).should be_true }
  end

end