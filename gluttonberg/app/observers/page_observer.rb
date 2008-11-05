module Gluttonberg
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
            :dialect  => dialect,
            :locale   => locale
          )
        end
      end
      Merb.logger.info("Generating stubbed content for new page")
      type.sections.each do |section|
        # Create the content
        association = send(section.type)
        content = association.create(:section => section)
        # Create each localization
        if content.model.localized?
          localizations.all.each do |localization|
            content.localizations.create(:parent => content, :page_localization => localization)
          end
        end
      end      
    end

    # This updates localizations which don't have a slug set. In that case they 
    # need to fallback to the default stored in the page. If that changes, then 
    # all those relying on the default have to be recached again.
    after :update do
      if paths_need_recaching?
        localizations.all(:slug => nil).each do |localization|
          new_path = if localization.path.count("/") > 0
            "#{localization.path.match(%r{(\S+)/\w+})[1]}/#{slug}"
          else
            slug
          end
          # Save the path in the localization
          localization.update_attributes(:path => new_path)
        end
      end
    end
    
    # A dirty hack to remove the page localizations after a page is destroyed.
    # This is in lieu of a :dependent option in DM associations
    after :destroy do
      page_localizations = PageLocalization.all(:page_id => id)
      page_localization_ids = page_localizations.collect { |l| l.id }
      # Destroy the localizations first, then the main content record
      Gluttonberg::Content.content_classes.each do |klass|
        if klass.localized?
          klass.localizations.model.all(:page_localization_id => page_localization_ids).destroy!
        end
        klass.all(:page_id => id).destroy!
      end
      page_localizations.destroy!
    end
  end
end