class PageLocalizationObserver
  include DataMapper::Observer
  
  observe PageLocalization
  
  # Every time the localization is updated, we need to check to see if the 
  # slug has been updated. If it has, we need to update it’s cached path
  # and also the paths for all it’s decendants.
  before :save do
    if attribute_dirty?(:slug) || new_record?
      @paths_need_recaching = true

      parent = page.parent.localizations.first({:locale_id => locale_id, :dialect_id => dialect_id})
      attribute_set(:path, "#{parent_path}/#{slug}")
    end
  end
  
  # This is the business end. If the paths do have to be recached, we pile
  # through all the decendent localizations
  after :save do
    decendants = page.children.localizations.all({:locale_id => locale_id, :dialect_id => dialect_id})
    decendants.each { |l| l.cache_path!(path) } unless decendants.empty?
  end
end