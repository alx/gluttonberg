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
  
  # Check to see if we need to update articles or cascade through 
  # localizations to update the slugs.
  # before :save do
  #   @articles_need_updating = true if attribute_dirty?(:template_id)
  #   @paths_need_updating = true if attribute_dirty?(:slug)
  # end
  
  # Handles two cases. One if the template is changed. The other if the slug
  # for the page has changed.
  #
  # Check to see if the template has changed. If it has, we can assume that
  # the sections specified are out of date and we need to fit the existing ones
  # into slots where they will fit. For any that are missing, create new ones.
  # For any excess — say a template with two sections is swapped with one with 
  # a single section — flag the content as orphaned.
  #
  # If the slug has changed, we need to go through all the decendent 
  # localizations and assign a new path to those that don't have a slug explicitly
  # set — i.e. it falls back to the page default — and also update the decendent
  # localizations of those records.
  after :save do
    if @articles_need_updating
      Merb.logger.info("Assigning page content to new template sections")
      # Go through the existing articles and assign them to the available 
      # sections. If we run out of sections, mark the article as orphaned.
      articles.each_with_index do |article, i|
        if section = template.sections[i]
          article.update_attributes(:section_name => section.name, :orphaned => false)
        else
          article.update_attributes(:orphaned => true)
        end
      end
      # Check to see if there are any dangling sections, and generate new 
      # articles for any that are missing.
      if articles.length < template.sections.length
        remaining_sections = template.sections[(articles.length - 1)..(template.sections.length - 1)]
        remaining_sections.each do |section|
          Article.create(:page => self, :section_name => section.name)
        end
      end
    end

    if @paths_need_updating
      
    end
  end
end