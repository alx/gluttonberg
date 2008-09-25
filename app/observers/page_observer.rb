class PageObserver
  include DataMapper::Observer
  
  observe Page
  
  # Generate a series of content models for this page based on the specified
  # template. These models will be empty, but ready to be displayed in the 
  # admin interface for editing.
  after :create do
    Merb.logger.info("Generating page localizations")
    Locale.all.each do |locale|
      locale.dialects.all.each do |dialect|
        loc = localizations.create(
          :name     => name, 
          :slug     => slug, 
          :dialect  => dialect,
          :locale   => locale
        )
      end
    end
    Merb.logger.info("Generating stubbed content for new page")
    template.sections.each do |section|
      # Create the content
      association = send(section.type.pluralize)
      content = association.create(:section => section)
      # Create each localization
      localizations.all.each do |localization|
        content.localizations.create(:parent => content, :page_localization => localization)
      end
    end
  end
end