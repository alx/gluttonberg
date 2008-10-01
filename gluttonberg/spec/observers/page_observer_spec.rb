require File.join( File.dirname(__FILE__), '..', "spec_helper" )
require Merb.root / "app" / "observers" / "page_observer"

# Clear everything ready to go anew
models = [Page, PageLocalization, RichTextContent, RichTextContent::Localization, Locale, Dialect]
models.each { |model| model.all.destroy! }

# Generate new fixtures
3.of { Dialect.generate }
2.of { Locale.generate }
Template.generate(:view, :sections => 2.of { TemplateSection.generate })
Page.generate

describe PageObserver do
  before :all do
    @page = Page.first
  end
  
  it "should generate localizations" do
    @page.localizations.length.should == 2
  end
  
  it "should generate content for template section" do
    count = @page.template.sections.length * 2
    @page.contents.length.should == count
  end
  
  it "should generate the content localizations" do
    count = Locale.all.inject(0) do |memo, locale|
      memo += locale.dialects.length
      memo
    end
    @page.rich_text_contents.localizations.should == count
  end
end