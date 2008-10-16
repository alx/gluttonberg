module Gluttonberg
  class Page
    include DataMapper::Resource

    property :id,             Integer,  :serial => true, :key => true
    property :parent_id,      Integer
    property :layout_id,      Integer
    property :name,           String,   :length => 1..100
    property :slug,           String,   :length => 1..100
    property :template_name,  String,   :length => 0..100
    property :layout_name,    String,   :length => 0..100
    property :home,           Boolean,  :default => false,  :writer => :private
    property :created_at,     Time
    property :updated_at,     Time

    before :save, :cache_template_and_layout_name
    after  :save, :check_for_home_update
    #validate_uniqueness_of :slug, :event => :save, :scope => [:parent_id]

    is_list :scope => [:parent_id]
    is_tree

    has n,      :localizations, :class_name => "Gluttonberg::PageLocalization"
    has n,      :children,      :class_name => "Gluttonberg::Page",      :child_key => [:parent_id]
    belongs_to  :layout
    belongs_to  :type,          :class_name => "Gluttonberg::PageType"

    attr_accessor :current_localization, :dialect_id, :locale_id, :paths_need_recaching

    def slug=(new_slug)
      @paths_need_recaching = true
      attribute_set(:slug, new_slug)
    end

    def paths_need_recaching?
      @paths_need_recaching
    end

    # Returns all the content classes for this page. This is a slightly naive 
    # implementation in that it just iterates over the content associations and
    # calls all on each.
    def contents
      @contents ||= Glutton::Content.content_associations.inject([]) do |memo, assoc|
        memo += send(assoc).all
        memo
      end
    end

    # This finder grabs the matching page and under the hood also grabs the 
    # relevant localization.
    #
    # FIXME: The way errors are raised here is ver nasty, needs fixing up 
    def self.first_with_localization(options)
      if options[:path] == "/"
        options.delete(:path)
        page = Page.first(:home => true)
        raise DataMapper::ObjectNotFoundError unless page
        localization = page.localizations.first(options)
        raise DataMapper::ObjectNotFoundError unless localization
      else
        localization = PageLocalization.first(options)
        raise DataMapper::ObjectNotFoundError unless localization
        page = localization.page
      end
      page.current_localization = localization
      page
    end

    # Checks to see if a layout has actually been set, otherwise it falls back
    # to the default "public"
    def layout_name
      attribute_get(:layout_name) || "public"
    end

    # Checks to see if a template has been set, otherwise it falls back and
    # returns the default: "default"
    def template_name
      attribute_get(:template_name) || "default"
    end

    def home=(state)
      attribute_set(:home, state)
      @home_updated = state
    end

    # Sets and saves the page’s path using the prefix passed in. This is intended
    # to be used by the parent page as part of a cascading update i.e. a parent 
    # page changes it’s path, so all the child pages need to have their paths
    # updated.
    def cache_path!(locale, path)
      new_path = "#{path}/#{slug}"
      # Save the path for the specified localization
      local = localizations.first(:locale => locale)
      local.update_attributes(:path => "#{path}/#{local.slug}") if local
      # Cascade down into the other pages
      next_generation.each { |descendant| descendant.cache_path!(locale, new_path) }
    end

    private

    def cache_template_and_layout_name
      attribute_set(:template_name, type.file_name) if attribute_dirty?(:template_id)
      attribute_set(:layout_name, layout.file_name) if attribute_dirty?(:layout_id)
    end

    # Checks to see if this page has been set as the homepage. If it has, we 
    # then go and 
    def check_for_home_update
      if @home_updated && @home_updated == true
        previous_home = Page.first(:home => true, :id.not => id)
        previous_home.update_attributes(:home => false) if previous_home
      end
    end
  end
  
end