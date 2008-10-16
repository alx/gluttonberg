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
        localizations.all.each do |localization|
          content.localizations.create(:parent => content, :page_localization => localization)
        end
      end
    end

    # This updates localizations which don't have a slug set. In that case they 
    # need to fallback to the default stored in the page. If that changes, then 
    # all those relying on the default have to be recached again.
    after :update do
      if paths_need_recaching?
        localizations.all(:slug => nil).each do |localization|
          # This accounts for the following possibilities:
          # "/"
          # "/bit"
          # "/more/complex"
          path_prefix = if localization.path == "/"
            localization.path
          elsif localization.path.count("/") == 1
            localization.path.match(/(\/\S+)/)[1]
          else
            localization.path.match(/(\/\S+)\/\w+/)[1]
          end
          # Save the path in the localization
          localization.update_attributes(:path => "#{path_prefix}/#{slug}")
        end
      end
    end
  end
end