require File.join( File.dirname(__FILE__), '..', "spec_helper" )
require Merb.root / "app" / "observers" / "page_localization_observer"

2.of { Dialect.generate }
2.of { Locale.generate }
Template.generate(:view)
Template.generate(:layout)
Page.generate
2.of { PageLocalization.generate }

describe PageLocalizationObserver do
  it "should generate path for new localizations" do
    localization = PageLocalization.create(:page => Page.first)
  end
  
  it "should generate path for updated localizations"
  
  it "should generate paths for child localizations"
end