module Gluttonberg
  class PageLocalizationObserver
    include DataMapper::Observer

    observe PageLocalization

    # Every time the localization is updated, we need to check to see if the 
    # slug has been updated. If it has, we need to update itâ€™s cached path
    # and also the paths for all itâ€™s decendants.
    before :valid? do
      if attribute_dirty?(:slug) || new_record?
        @paths_need_recaching = true
        regenerate_path 
      elsif attribute_dirty?(:path)
        @paths_need_recaching = true
      end
    end

    # This is the business end. If the paths do have to be recached, we pile
    # through all the decendent localizations and tell each of those to recache.
    # Each of those will then also be observed and have their children updated
    # as well.
    after :save do
      if paths_need_recaching? and !page.children.empty?
        decendants = page.children.localizations.all({:locale_id => locale_id, :dialect_id => dialect_id})
        unless decendants.empty?
          decendants.each do |l| 
            l.paths_need_recaching = true
            l.update_attributes(:path => "#{path}/#{l.slug || l.page.slug}") 
          end 
        end
      end
    end
  end
end
