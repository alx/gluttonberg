module Gluttonberg
  class Page
    include DataMapper::Resource

    property :id,               Integer,  :serial => true, :key => true
    property :parent_id,        Integer
    property :layout_id,        Integer
    property :name,             String,   :length => 1..100
    property :navigation_label, String,   :length => 0..100
    property :slug,             String,   :length => 1..100
    property :template_name,    String,   :length => 0..100
    property :layout_name,      String,   :length => 0..100
    property :home,             Boolean,  :default => false,  :writer => :private
    property :behaviour,        Enum[:default, :dynamic, :component], :default => :default
    property :component,        String,   :length => 0...100
    property :created_at,       Time
    property :updated_at,       Time

    before :save, :cache_template_and_layout_name
    before :valid?, :slug_management
    after  :save, :check_for_home_update
    #validate_uniqueness_of :slug, :event => :save, :scope => [:parent_id]

    is_list :scope => [:parent_id]
    is_tree

    has n,      :localizations,       :class_name => "Gluttonberg::PageLocalization"
    has n,      :children,            :class_name => "Gluttonberg::Page", :child_key => [:parent_id]
    belongs_to  :layout
    belongs_to  :type,                :class_name => "Gluttonberg::PageType"
    belongs_to  :passthrough_target,  :class_name => "Gluttonberg::Page"

    attr_accessor :current_localization, :dialect_id, :locale_id, :paths_need_recaching
    
    # Returns the localized navigation label, or falls back to the page for a
    # the default.
    def nav_label
      if current_localization.navigation_label.blank?
        if navigation_label.blank?
          name
        else
          navigation_label
        end
      else
        current_localization.navigation_label
      end
    end

    # Returns the localized title for the page or a default
    def title
      current_localization.name.blank? ? attribute_get(:name) : current_localization.name
    end
    
    # Delegates to the current_localization
    def path
      current_localization.path
    end

    # Returns a hash containing the paths to the page and layout templates.
    def template_paths(opts = {})
      {:page => PageType.template_for(template_name, opts), :layout => Layout.template_for(layout_name, opts)}
    end

    def slug=(new_slug)
      puts "setting the slug"
      @paths_need_recaching = true
      #if you're changing this regex, make sure to change the one in /javascripts/slug_management.js too
      new_slug = new_slug.downcase.gsub(/\s/, '_').gsub(/[\!\*'"″′‟‛„‚”“”˝\(\)\;\:\@\&\=\+\$\,\/?\%\#\[\]]/, '')
      attribute_set(:slug, new_slug)
    end

    def paths_need_recaching?
      @paths_need_recaching
    end

    # Just palms off the request for the contents to the current localization
    def localized_contents
      @contents ||= begin
        Content.content_associations.inject([]) do |memo, assoc|
          memo += send(assoc).all_with_localization(:page_localization_id => current_localization.id)
        end
      end
    end

    # This finder grabs the matching page and under the hood also grabs the 
    # relevant localization.
    #
    # FIXME: The way errors are raised here is ver nasty, needs fixing up 
    def self.first_with_localization(options)
      if options[:path] == "" or options[:path].nil?
        options.delete(:path)
        page = Page.first(:home => true)
        return nil unless page
        localization = page.localizations.first(options)
        return nil unless localization
      else
        localization = PageLocalization.first(options)
        return nil unless localization
        page = localization.page
      end
      page.current_localization = localization
      page
    end
    
    # Returns the matching pages with their specified localizations preloaded
    def self.all_with_localization(conditions)
      l_conditions = extract_localization_conditions(conditions)
      all(conditions).each {|p| p.load_localization(l_conditions)}
    end

    # Returns the immediate children of this page, which the specified
    # localization preloaded.
    # TODO: Have this actually check the current mode
    def children_with_localization(conditions)
      l_conditions = self.class.extract_localization_conditions(conditions)
      children.all(conditions).each { |c| c.load_localization(l_conditions)}
    end
    
    # Load the matching localization as specified in the options
    def load_localization(conditions = {})
      # OMGWTFBBQ: I shouldn't have explicitly set the id in the conditions
      # like this, since I’m going through an association.
      conditions[:page_id] = id 
      @current_localization = localizations.first(conditions) unless conditions.empty?
    end
    
    # Checks to see if a layout has actually been set, otherwise it falls back
    # to the default "public"
    def layout_name
      attribute_get(:layout_name) || "default"
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

    private

    def cache_template_and_layout_name
      attribute_set(:template_name, type.filename) if attribute_dirty?(:page_type_id)
      attribute_set(:layout_name, layout.filename) if attribute_dirty?(:layout_id)
    end

    def slug_management
      puts "Hey, I'm managing a slug here, slug: #{slug.inspect}, slug.blank?: #{slug.blank?.inspect}"
      @slug = name if @slug.blank?
    end

    # Checks to see if this page has been set as the homepage. If it has, we 
    # then go and 
    def check_for_home_update
      if @home_updated && @home_updated == true
        previous_home = Page.first(:home => true, :id.not => id)
        previous_home.update_attributes(:home => false) if previous_home
      end
    end
    
    private
    
    def self.extract_localization_conditions(opts)
      conditions = [:dialect, :locale].inject({}) do |memo, opt|
        memo[:"#{opt}_id"] = opts.delete(opt).id if opts[opt]
        memo
      end
    end
  end
  
end